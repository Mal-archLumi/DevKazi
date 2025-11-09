// chat.controller.ts
import { Controller, Get, Param, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { ChatService } from './chat.service';

interface PopulatedSender {
  _id: any;
  name?: string;
  email?: string;
  username?: string;
  firstName?: string;
  lastName?: string;
}

interface PopulatedMessage {
  _id: any;
  team: any;
  sender: PopulatedSender;
  content: string;
  timestamp: Date;
}

@Controller('chat')
export class ChatController {
  constructor(private chatService: ChatService) {}

  @Get('teams/:teamId/messages')
  @UseGuards(JwtAuthGuard)
  async getTeamMessages(@Param('teamId') teamId: string) {
    const messages = await this.chatService.getTeamMessages(teamId) as unknown as PopulatedMessage[];
    
    return messages.map(m => ({
      id: m._id.toString(),
      teamId: m.team.toString(),
      senderId: m.sender._id.toString(),
      senderName: m.sender.name || 'User',
      content: m.content,
      timestamp: m.timestamp,
    }));
  }
}