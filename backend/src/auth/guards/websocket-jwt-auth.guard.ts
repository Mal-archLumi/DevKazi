// src/auth/guards/websocket-jwt-auth.guard.ts
import { Injectable, ExecutionContext, Logger } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { WsException } from '@nestjs/websockets';

@Injectable()
export class WebSocketJwtAuthGuard extends AuthGuard('ws-jwt') {
  private readonly logger = new Logger(WebSocketJwtAuthGuard.name);

  getRequest(context: ExecutionContext) {
    const client = context.switchToWs().getClient();
    const { handshake } = client;

    this.logger.debug('Handshake Auth:', handshake.auth);
    this.logger.debug('Handshake Query:', handshake.query);
    this.logger.debug('Handshake Headers:', handshake.headers);

    // 1. auth object (recommended)
    let token = handshake.auth?.token;

    // 2. query fallback
    if (!token && handshake.query?.token) {
      token = Array.isArray(handshake.query.token)
        ? handshake.query.token[0]
        : handshake.query.token;
    }

    // 3. Authorization header fallback
    if (!token && handshake.headers?.authorization?.startsWith('Bearer ')) {
      token = handshake.headers.authorization.substring(7);
    }

    if (!token) throw new WsException('No auth token');

    // Passport expects a request-like object with a Bearer header
    return { headers: { authorization: `Bearer ${token}` }, handshake };
  }

  handleRequest(err: any, user: any, info: any, context: ExecutionContext) {
    if (err || !user) {
      this.logger.warn(`WebSocket auth failed: ${info?.message || err}`);
      throw new WsException('Unauthorized');
    }

    const client = context.switchToWs().getClient();
    client.data.user = user;
    this.logger.log(`WebSocket authenticated user: ${user.userId}`);

    //logging 
    this.logger.log(`GUARD SUCCESS: Setting client.data.user = ${user.userId} (id: ${client.id})`);
    this.logger.debug(`Guard received user: ${JSON.stringify(user)}`);


    return user;               // <-- critical
  }


  canActivate(context: ExecutionContext) {
    return super.canActivate(context);
  }
}