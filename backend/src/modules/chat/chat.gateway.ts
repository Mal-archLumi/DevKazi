import { WebSocketGateway, SubscribeMessage, MessageBody, ConnectedSocket } from '@nestjs/websockets';
import { ChatService } from './chat.service';
import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@WebSocketGateway({ cors: true })
@UseGuards(JwtAuthGuard)
export class ChatGateway {
  constructor(private readonly chatService: ChatService) {}

  @SubscribeMessage('joinTeam')
  async handleJoinTeam(@MessageBody() data: { teamId: string }, @ConnectedSocket() client: any) {
    client.join(data.teamId);
  }

  @SubscribeMessage('sendMessage')
  async handleMessage(@MessageBody() data: any, @ConnectedSocket() client: any) {
    const message = await this.chatService.createMessage(data);
    client.to(data.team).emit('newMessage', message);
    return message;
  }
}