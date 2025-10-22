import { 
  WebSocketGateway, 
  WebSocketServer, 
  SubscribeMessage, 
  MessageBody, 
  ConnectedSocket,
  OnGatewayConnection,
  OnGatewayDisconnect 
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { ChatService } from './chat.service';
import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@WebSocketGateway({ 
  cors: {
    origin: '*', // Configure based on your needs
    methods: ['GET', 'POST']
  }
})
@UseGuards(JwtAuthGuard)
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  constructor(private readonly chatService: ChatService) {}

  async handleConnection(client: Socket) {
    console.log(`Client connected: ${client.id}`);
  }

  async handleDisconnect(client: Socket) {
    console.log(`Client disconnected: ${client.id}`);
  }

  @SubscribeMessage('joinTeam')
  async handleJoinTeam(
    @MessageBody() data: { teamId: string }, 
    @ConnectedSocket() client: Socket
  ) {
    client.join(data.teamId);
    console.log(`Client ${client.id} joined team ${data.teamId}`);
  }

  @SubscribeMessage('sendMessage')
  async handleMessage(
    @MessageBody() data: { team: string; sender: string; content: string }, 
    @ConnectedSocket() client: Socket
  ) {
    try {
      const message = await this.chatService.createMessage(data);
      
      // Broadcast to all clients in the team room except sender
      client.to(data.team).emit('newMessage', message);
      
      // Also send back to sender for confirmation
      return { success: true, message };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  @SubscribeMessage('getTeamMessages')
  async handleGetTeamMessages(
    @MessageBody() data: { teamId: string },
    @ConnectedSocket() client: Socket
  ) {
    try {
      const messages = await this.chatService.getTeamMessages(data.teamId);
      return { success: true, messages };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }
}