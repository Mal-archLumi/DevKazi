import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
  OnGatewayConnection,
  OnGatewayDisconnect,
  OnGatewayInit,
} from '@nestjs/websockets';
import { UsePipes, ValidationPipe, Logger, UseGuards } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Server, Socket } from 'socket.io';
import { ChatService } from './chat.service';
import { ConfigService } from '@nestjs/config';
import { WebSocketJwtAuthGuard } from '../../auth/guards/websocket-jwt-auth.guard';

interface AuthenticatedSocket extends Socket {
  data: {
    user?: {
      userId: string;
      email: string | null;
      name: string;
      isVerified: boolean;
    };
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
export class ChatGateway implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(ChatGateway.name);

  constructor(
    private readonly chatService: ChatService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  // Set up middleware to authenticate BEFORE connection
  afterInit(server: Server) {
    this.logger.log('🚀 WebSocket Gateway initialized');
    
    // Add authentication middleware
    server.use(async (socket: AuthenticatedSocket, next) => {
      try {
        this.logger.debug('🔍 WebSocket Middleware - Authenticating connection');
        this.logger.debug('🔍 Query:', socket.handshake.query);
        this.logger.debug('🔍 Auth:', socket.handshake.auth);
        this.logger.debug('🔍 Headers:', socket.handshake.headers);

        // Extract token from multiple possible locations
        let token: string | undefined;

        // 1. Check handshake.auth.token (standard Socket.IO auth)
        if (socket.handshake.auth?.token) {
          token = socket.handshake.auth.token;
          this.logger.debug('✅ Token found in auth.token');
        }
        // 2. Check handshake.headers.authorization (HTTP-style auth)
        else if (socket.handshake.headers?.authorization) {
          const authHeader = socket.handshake.headers.authorization as string;
          token = authHeader.replace('Bearer ', '');
          this.logger.debug('✅ Token found in headers.authorization');
        }
        // 3. Check handshake.query.token (query parameter)
        else if (socket.handshake.query?.token) {
          token = socket.handshake.query.token as string;
          this.logger.debug('✅ Token found in query.token');
        }

        if (!token) {
          this.logger.error('❌ No token found in handshake');
          return next(new Error('Authentication token required'));
        }

        // Verify JWT token
        const jwtSecret = this.configService.get<string>('JWT_SECRET');
        const payload = await this.jwtService.verifyAsync(token, {
          secret: jwtSecret,
        });

        if (!payload || !payload.sub) {
          this.logger.error('❌ Invalid token payload');
          return next(new Error('Invalid token'));
        }

        // Attach user to socket BEFORE connection
        socket.data.user = {
          userId: payload.sub,
          email: payload.email || null,
          name: payload.name || 'User',
          isVerified: payload.isVerified || false,
        };

        this.logger.log(`✅ WebSocket authenticated in middleware: User ${payload.sub}`);
        next();

      } catch (error) {
        this.logger.error(`❌ WebSocket auth middleware failed: ${error.message}`);
        next(new Error('Authentication failed: ' + error.message));
      }
    });
  }

  // NOW handleConnection will have the user already attached
  async handleConnection(client: AuthenticatedSocket) {
    try {
      const user = client.data.user;

      if (!user) {
        this.logger.error(`❌ No user in client.data - Auth failed`);
        client.emit('connection_error', { 
          message: 'Authentication failed - no user data' 
        });
        client.disconnect();
        return;
      }

      this.logger.log(`✅ Client connected and authenticated: ${client.id} | User: ${user.userId}`);
      
      // Send immediate connection success
      client.emit('connection_success', {
        message: 'Successfully connected and authenticated',
        userId: user.userId,
        userName: user.name,
        timestamp: new Date().toISOString()
      });

      // Join team room immediately if teamId is provided in handshake
      const teamId = client.handshake.query.teamId as string;
      if (teamId) {
        client.join(teamId);
        this.logger.log(`✅ User ${user.userId} auto-joined team ${teamId}`);
        
        // Notify others in team
        client.to(teamId).emit('user_joined', {
          userId: user.userId,
          userName: user.name,
          teamId: teamId,
          timestamp: new Date().toISOString()
        });
      }

    } catch (error: any) {
      this.logger.error(`💥 Connection error for client ${client.id}: ${error.message}`);
      client.emit('connection_error', { 
        message: 'Connection failed: ' + error.message 
      });
      client.disconnect();
    }
  }

  handleDisconnect(client: AuthenticatedSocket) {
    const user = client.data.user;
    this.logger.log(`🔌 Client disconnected: ${client.id} | User: ${user?.userId || 'Unknown'}`);
    
    // Notify all rooms the user was in
    const rooms = Array.from(client.rooms).filter(room => room !== client.id);
    rooms.forEach(teamId => {
      client.to(teamId).emit('user_left', {
        userId: user?.userId,
        userName: user?.name,
        teamId: teamId,
        timestamp: new Date().toISOString()
      });
    });
  }

  @SubscribeMessage('join_team')
  @UseGuards(WebSocketJwtAuthGuard)
  async handleJoinTeam(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() { teamId }: { teamId: string },
  ) {
    try {
      const user = client.data.user!;
      
      if (!teamId) {
        client.emit('error', { message: 'Team ID is required' });
        return;
      }

      client.join(teamId);
      this.logger.log(`✅ User ${user.userId} manually joined team ${teamId}`);
      
      client.emit('joined_team', { 
        success: true, 
        teamId,
        message: `Successfully joined team ${teamId}`
      });

      // Notify other users in the team
      client.to(teamId).emit('user_joined', {
        userId: user.userId,
        userName: user.name,
        teamId: teamId,
        timestamp: new Date().toISOString()
      });

    } catch (error: any) {
      this.logger.error(`❌ Join team error: ${error.message}`);
      client.emit('error', { 
        message: 'Failed to join team: ' + error.message 
      });
    }
  }

  @SubscribeMessage('send_message')
  @UseGuards(WebSocketJwtAuthGuard)
  async handleSendMessage(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() { teamId, content }: { teamId: string; content: string },
  ) {
    try {
      const user = client.data.user!;

      if (!content?.trim()) {
        client.emit('error', { message: 'Message content cannot be empty' });
        return;
      }

      if (!teamId) {
        client.emit('error', { message: 'Team ID is required' });
        return;
      }

      // Check if user is in the team room
      const rooms = Array.from(client.rooms);
      if (!rooms.includes(teamId)) {
        client.emit('error', { message: 'You are not a member of this team' });
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

      // Broadcast to all in the team room including sender
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

  @SubscribeMessage('leave_team')
  @UseGuards(WebSocketJwtAuthGuard)
  async handleLeaveTeam(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() { teamId }: { teamId: string },
  ) {
    try {
      const user = client.data.user!;

      if (!teamId) {
        client.emit('error', { message: 'Team ID is required' });
        return;
      }

      client.leave(teamId);
      this.logger.log(`🚪 User ${user.userId} left team ${teamId}`);
      
      client.emit('left_team', { 
        success: true, 
        teamId,
        message: `Successfully left team ${teamId}`
      });

      // Notify other users in the team
      client.to(teamId).emit('user_left', {
        userId: user.userId,
        userName: user.name,
        teamId: teamId,
        timestamp: new Date().toISOString()
      });

    } catch (error: any) {
      this.logger.error(`❌ Leave team error: ${error.message}`);
      client.emit('error', { 
        message: 'Failed to leave team: ' + error.message 
      });
    }
  }

  @SubscribeMessage('typing_start')
  @UseGuards(WebSocketJwtAuthGuard)
  async handleTypingStart(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() { teamId }: { teamId: string },
  ) {
    try {
      const user = client.data.user!;

      if (!teamId) {
        return;
      }

      // Notify others in the team that user is typing
      client.to(teamId).emit('user_typing', {
        userId: user.userId,
        userName: user.name,
        teamId: teamId,
        isTyping: true
      });

    } catch (error: any) {
      this.logger.error(`❌ Typing start error: ${error.message}`);
    }
  }

  @SubscribeMessage('typing_stop')
  @UseGuards(WebSocketJwtAuthGuard)
  async handleTypingStop(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() { teamId }: { teamId: string },
  ) {
    try {
      const user = client.data.user!;

      if (!teamId) {
        return;
      }

      // Notify others in the team that user stopped typing
      client.to(teamId).emit('user_typing', {
        userId: user.userId,
        userName: user.name,
        teamId: teamId,
        isTyping: false
      });

    } catch (error: any) {
      this.logger.error(`❌ Typing stop error: ${error.message}`);
    }
  }

  @SubscribeMessage('ping')
  handlePing(@ConnectedSocket() client: AuthenticatedSocket) {
    client.emit('pong', { 
      timestamp: new Date().toISOString(),
      serverTime: Date.now()
    });
  }

  @SubscribeMessage('get_online_users')
  @UseGuards(WebSocketJwtAuthGuard)
  async handleGetOnlineUsers(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() { teamId }: { teamId: string },
  ) {
    try {
      if (!teamId) {
        client.emit('error', { message: 'Team ID is required' });
        return;
      }

      // Get all sockets in the team room
      const sockets = await this.server.in(teamId).fetchSockets();
      const onlineUsers = sockets
        .map(socket => (socket as unknown as AuthenticatedSocket).data.user)
        .filter(user => user != null)
        .map(user => ({
          userId: user!.userId,
          name: user!.name,
          email: user!.email
        }));

      client.emit('online_users', {
        teamId,
        users: onlineUsers
      });

    } catch (error: any) {
      this.logger.error(`❌ Get online users error: ${error.message}`);
      client.emit('error', { 
        message: 'Failed to get online users: ' + error.message 
      });
    }
  }

  // Health check endpoint
  @SubscribeMessage('health_check')
  handleHealthCheck(@ConnectedSocket() client: AuthenticatedSocket) {
    const user = client.data.user;
    client.emit('health_response', {
      status: 'healthy',
      userId: user?.userId,
      authenticated: !!user,
      connected: true,
      timestamp: new Date().toISOString()
    });
  }

  // Get connection info
  @SubscribeMessage('connection_info')
  handleConnectionInfo(@ConnectedSocket() client: AuthenticatedSocket) {
    const user = client.data.user;
    const rooms = Array.from(client.rooms);
    
    client.emit('connection_info_response', {
      socketId: client.id,
      userId: user?.userId,
      authenticated: !!user,
      joinedRooms: rooms.filter(room => room !== client.id), // Exclude private room
      timestamp: new Date().toISOString()
    });
  }
}