// websocket-jwt-auth.guard.ts
import { CanActivate, ExecutionContext, Injectable, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { Socket } from 'socket.io';

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

@Injectable()
export class WebSocketJwtAuthGuard implements CanActivate {
  private readonly logger = new Logger(WebSocketJwtAuthGuard.name);

  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const client: AuthenticatedSocket = context.switchToWs().getClient();
    
    try {
      // Log handshake details for debugging
      this.logger.debug('🔍 WebSocket Connection - Handshake Query:', client.handshake.query);
      this.logger.debug('🔍 WebSocket Connection - Handshake Headers:', client.handshake.headers);
      this.logger.debug('🔍 WebSocket Connection - Handshake Auth:', client.handshake.auth);

      // Extract token from multiple possible locations
      let token: string | undefined;

      // 1. Check handshake.auth.token (standard Socket.IO auth)
      if (client.handshake.auth?.token) {
        token = client.handshake.auth.token;
        this.logger.debug('✅ Token found in handshake.auth.token');
      }
      // 2. Check handshake.headers.authorization (HTTP-style auth)
      else if (client.handshake.headers?.authorization) {
        const authHeader = client.handshake.headers.authorization as string;
        token = authHeader.replace('Bearer ', '');
        this.logger.debug('✅ Token found in handshake.headers.authorization');
      }
      // 3. Check handshake.query.token (query parameter)
      else if (client.handshake.query?.token) {
        token = client.handshake.query.token as string;
        this.logger.debug('✅ Token found in handshake.query.token');
      }

      if (!token) {
        this.logger.error('❌ No token found in handshake');
        client.emit('authentication_error', { 
          message: 'No authentication token provided' 
        });
        return false;
      }

      // Verify JWT token
      const jwtSecret = this.configService.get<string>('JWT_SECRET');
      const payload = await this.jwtService.verifyAsync(token, {
        secret: jwtSecret,
      });

      if (!payload || !payload.sub) {
        this.logger.error('❌ Invalid token payload');
        client.emit('authentication_error', { 
          message: 'Invalid token' 
        });
        return false;
      }

      // Attach user to socket
      client.data.user = {
        userId: payload.sub,
        email: payload.email || null,
        name: payload.name || 'User',
        isVerified: payload.isVerified || false,
      };

      this.logger.log(`✅ WebSocket authenticated: User ${payload.sub}`);
      return true;

    } catch (error) {
      this.logger.error(`❌ WebSocket auth failed: ${error.message}`);
      client.emit('authentication_error', { 
        message: 'Authentication failed: ' + error.message 
      });
      return false;
    }
  }
}