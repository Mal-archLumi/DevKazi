// src/modules/chat/chat.gateway.ts
import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { UsePipes, ValidationPipe, Logger, Inject } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Server, Socket } from 'socket.io';
import { ChatService } from './chat.service';
import { ConfigService } from '@nestjs/config';

interface AuthenticatedSocket extends Socket {
  data: {
    user?: {
      userId: string;
      email: string | null;
      name: string;
      isVerified: boolean;
    };
    isAuthenticated?: boolean;
    authAttempts?: number;
  };
}

@WebSocketGateway({
  cors: {
    origin: '*',
    credentials: true,
  },
  pingTimeout: 60000,
  pingInterval: 25000,
  transports: ['websocket', 'polling'],
  allowEIO3: true,
})
@UsePipes(new ValidationPipe())
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(ChatGateway.name);

  constructor(
    private readonly chatService: ChatService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async handleConnection(client: AuthenticatedSocket) {
    this.logger.debug(`🔄 New connection attempt: ${client.id}`);

    try {
      // Initialize authentication state
      client.data.isAuthenticated = false;
      client.data.authAttempts = 0;
      
      const handshake = client.handshake;
      this.logger.debug(`📋 Handshake Auth: ${JSON.stringify(handshake.auth)}`);
      this.logger.debug(`📋 Handshake Query: ${JSON.stringify(handshake.query)}`);
      this.logger.debug(`📋 Handshake Headers: ${JSON.stringify(handshake.headers)}`);

      // Extract token from ALL possible locations
      let token: string | null = null;

      // 1. Check handshake auth (Socket.IO v4+)
      if (handshake.auth?.token) {
        token = handshake.auth.token;
        this.logger.debug('✅ Token found in handshake.auth');
      }
      
      // 2. Check query parameters (Socket.IO v2/v3)
      if (!token && handshake.query?.token) {
        token = Array.isArray(handshake.query.token) 
          ? handshake.query.token[0] 
          : handshake.query.token;
        this.logger.debug('✅ Token found in handshake.query');
      }

      // 3. Check Authorization header
      if (!token && handshake.headers?.authorization) {
        const authHeader = handshake.headers.authorization;
        if (authHeader.startsWith('Bearer ')) {
          token = authHeader.substring(7);
          this.logger.debug('✅ Token found in Authorization header');
        }
      }

      if (token) {
        // Try to authenticate with the token from handshake
        await this.authenticateClient(client, token);
      } else {
        this.logger.warn(`❌ No token found in handshake for client ${client.id}`);
        this.logger.debug('Waiting for manual authentication...');
        
        // 🚨 CRITICAL: Don't disconnect - wait for manual authentication
        client.emit('authentication_required', { 
          message: 'Authentication token required. Please send authenticate event with token.' 
        });
        
        // Set a timeout to disconnect if no authentication happens
        setTimeout(() => {
          if (!client.data.isAuthenticated) {
            this.logger.warn(`⏰ Authentication timeout for client ${client.id}`);
            client.emit('authentication_timeout', { 
              message: 'Authentication timeout. Please reconnect with valid token.' 
            });
            client.disconnect();
          }
        }, 30000); // 30 second timeout
      }

    } catch (error: any) {
      this.logger.error(`💥 Connection error for client ${client.id}: ${error.message}`);
      client.emit('connection_error', { 
        message: 'Connection failed: ' + error.message 
      });
      client.disconnect();
    }
  }

  private async authenticateClient(client: AuthenticatedSocket, token: string): Promise<void> {
    try {
      client.data.authAttempts = (client.data.authAttempts || 0) + 1;
      this.logger.debug(`🔐 Authentication attempt ${client.data.authAttempts} for client ${client.id}`);

      // Verify token
      const secret = this.configService.get<string>('JWT_SECRET');
      if (!secret) {
        throw new Error('JWT_SECRET not configured');
      }

      const payload = this.jwtService.verify(token, { secret });
      
      // Validate payload
      const userId = payload.sub || payload.userId;
      if (!userId) {
        throw new Error('JWT payload missing user identifier');
      }

      // Set user data and authentication state
      client.data.user = {
        userId: userId,
        email: payload.email || null,
        name: payload.name || 'Anonymous',
        isVerified: payload.isVerified || false,
      };
      client.data.isAuthenticated = true;

      this.logger.log(`✅ Client authenticated: ${client.id} | User: ${userId}`);
      
      // Send authentication success
      client.emit('authenticated', {
        success: true,
        userId: userId,
        user: client.data.user
      });

      // Send connection confirmation
      client.emit('connection_success', {
        message: 'Successfully connected and authenticated',
        userId: userId,
        timestamp: new Date().toISOString()
      });

    } catch (error: any) {
      this.logger.error(`❌ Authentication failed for client ${client.id}: ${error.message}`);
      client.emit('authentication_error', { 
        message: `Authentication failed: ${error.message}` 
      });
      
      // Don't disconnect immediately - allow manual auth retry
      if (client.data.authAttempts >= 3) {
        this.logger.warn(`🚫 Too many auth failures for client ${client.id}, disconnecting`);
        client.disconnect();
      }
    }
  }

  // Manual authentication fallback
  @SubscribeMessage('authenticate')
  async handleAuthenticate(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() data: { token: string },
  ) {
    try {
      this.logger.debug(`🔐 Manual authentication for client: ${client.id}`);

      if (!data?.token) {
        client.emit('authentication_error', { message: 'No token provided' });
        return;
      }

      await this.authenticateClient(client, data.token);

    } catch (error: any) {
      this.logger.error(`❌ Manual auth failed: ${error.message}`);
      client.emit('authentication_error', { 
        message: `Authentication failed: ${error.message}` 
      });
    }
  }

  handleDisconnect(client: AuthenticatedSocket) {
    const user = client.data.user;
    this.logger.log(`🔌 Client disconnected: ${client.id} | User: ${user?.userId || 'Unknown'} | Auth attempts: ${client.data.authAttempts || 0}`);
  }

  @SubscribeMessage('join_team')
  async handleJoinTeam(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() { teamId }: { teamId: string },
  ) {
    try {
      // Check if client is authenticated
      if (!client.data.isAuthenticated || !client.data.user) {
        this.logger.error(`❌ join_team: Client ${client.id} not authenticated`);
        client.emit('authentication_required', { 
          message: 'Please authenticate before joining a team' 
        });
        return;
      }

      const user = client.data.user;
      
      if (!teamId) {
        client.emit('error', { message: 'Team ID is required' });
        return;
      }

      client.join(teamId);
      this.logger.log(`✅ User ${user.userId} joined team ${teamId}`);
      
      client.emit('joined_team', { 
        success: true, 
        teamId,
        message: `Successfully joined team ${teamId}`
      });

    } catch (error: any) {
      this.logger.error(`❌ Join team error: ${error.message}`);
      client.emit('error', { 
        message: 'Failed to join team: ' + error.message 
      });
    }
  }

  @SubscribeMessage('send_message')
  async handleSendMessage(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() { teamId, content }: { teamId: string; content: string },
  ) {
    try {
      if (!client.data.isAuthenticated || !client.data.user) {
        client.emit('authentication_required', { message: 'Not authenticated' });
        return;
      }

      const user = client.data.user;

      if (!content?.trim()) {
        client.emit('error', { message: 'Message content cannot be empty' });
        return;
      }

      if (!teamId) {
        client.emit('error', { message: 'Team ID is required' });
        return;
      }

      this.logger.log(`💬 Sending message in team ${teamId} by user ${user.userId}`);

      const saved = await this.chatService.saveMessage({
        teamId,
        senderId: user.userId,
        content: content.trim(),
      });

      const message = {
        id: saved._id.toString(),
        teamId: saved.team.toString(),
        senderId: saved.sender.toString(),
        senderName: user.name || 'User',
        content: saved.content,
        timestamp: saved.timestamp || new Date(),
      };

      this.server.to(teamId).emit('new_message', message);
      
      client.emit('message_sent', { 
        success: true, 
        messageId: message.id 
      });
      
      this.logger.log(`✅ Message sent successfully in team ${teamId}`);

    } catch (error: any) {
      this.logger.error(`❌ Send message error: ${error.message}`);
      client.emit('error', { 
        message: 'Failed to send message: ' + error.message 
      });
    }
  }

  @SubscribeMessage('ping')
  handlePing(@ConnectedSocket() client: AuthenticatedSocket) {
    client.emit('pong', { 
      timestamp: new Date().toISOString(),
      serverTime: Date.now()
    });
  }
}