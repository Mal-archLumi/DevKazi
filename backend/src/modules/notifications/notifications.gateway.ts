// notifications.gateway.ts
import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { JwtService } from '@nestjs/jwt';

@WebSocketGateway({ namespace: 'notifications' })
export class NotificationsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer() server: Server;
  
  constructor(private jwtService: JwtService) {}
  
  async handleConnection(client: Socket) {
    try {
      const token = client.handshake.auth.token;
      const payload = await this.jwtService.verifyAsync(token);
      const userId = payload.userId || payload.sub;
      
      client.data.userId = userId;
      client.join(`user-${userId}`);
      
      console.log(`📡 Notification socket connected for user ${userId}`);
    } catch (error) {
      client.disconnect();
    }
  }
  
  handleDisconnect(client: Socket) {
    console.log(`📡 Notification socket disconnected for user ${client.data.userId}`);
  }
  
  // Send notification to specific user
  sendNotificationToUser(userId: string, notification: any) {
    this.server.to(`user-${userId}`).emit('new_notification', notification);
  }
  
  // Update unread count
  updateUnreadCount(userId: string, count: number) {
    this.server.to(`user-${userId}`).emit('unread_count_update', { count });
  }
}