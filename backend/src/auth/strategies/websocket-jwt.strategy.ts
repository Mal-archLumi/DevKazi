// src/auth/strategies/websocket-jwt.strategy.ts
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class WebSocketJwtStrategy extends PassportStrategy(Strategy, 'ws-jwt') {
  private readonly logger = new Logger(WebSocketJwtStrategy.name);

  constructor(private configService: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromExtractors([
        (request: any) => {
          // Try multiple extraction methods
          let token = null;
          
          // From handshake auth
          if (request.handshake?.auth?.token) {
            token = request.handshake.auth.token;
          }
          
          // From query parameters
          if (!token && request.handshake?.query?.token) {
            token = Array.isArray(request.handshake.query.token)
              ? request.handshake.query.token[0]
              : request.handshake.query.token;
          }
          
          // From authorization header
          if (!token && request.headers?.authorization) {
            const authHeader = request.headers.authorization;
            if (authHeader.startsWith('Bearer ')) {
              token = authHeader.substring(7);
            }
          }

          this.logger.debug(`Extracted token: ${token ? 'YES' : 'NO'}`);
          return token;
        },
      ]),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_SECRET') || 'fallback-secret',
    });
  }

  async validate(payload: any) {
  this.logger.debug(`Validating JWT payload: ${JSON.stringify(payload)}`);

  const userId = payload.sub || payload.userId;
  if (!userId) {
    this.logger.error('Invalid JWT payload - missing userId');
    throw new Error('Invalid JWT payload');
  }

  // Ensure object always returned
  return {
    userId,
    email: payload.email || null,
    name: payload.name || 'Anonymous',
    isVerified: payload.isVerified ?? false,
  };
}
}