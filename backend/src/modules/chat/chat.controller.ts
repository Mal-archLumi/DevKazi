// chat.controller.ts
import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { ChatService } from './chat.service';

interface PopulatedSender {
  _id?: any;
  name?: string;
  email?: string;
  username?: string;
  firstName?: string;
  lastName?: string;
}

interface PopulatedMessage {
  _id?: any;
  team?: any;
  sender?: PopulatedSender | null;
  content?: string;
  timestamp?: Date;
}

@Controller('chat')
export class ChatController {
  logger: any;
  messageModel: any;
  constructor(private chatService: ChatService) {}

  @Get('teams/:teamId/messages')
@UseGuards(JwtAuthGuard)
async getTeamMessages(@Param('teamId') teamId: string) {
  try {
    const messages = await this.chatService.getTeamMessages(teamId) as any[];
    
    const safeMessages = messages
      .filter(message => message && message._id) // Filter out null messages
      .map(message => {
        try {
          // Extract sender information with fallbacks for deleted users
          let senderId = 'unknown';
          let senderName = 'User';
          
          if (message.sender) {
            senderId = message.sender._id?.toString() || 'unknown';
            
            // Check if user is active/deleted
            if (message.sender.isActive === false || message.sender.name === 'Deleted User') {
              senderName = 'Deleted User';
            } else {
              senderName = message.sender.name || 
                          message.sender.username || 
                          (message.sender.firstName && message.sender.lastName ? 
                            `${message.sender.firstName} ${message.sender.lastName}` : 
                            'User');
            }
          }
          
          return {
            id: message._id.toString(),
            teamId: message.team?.toString() || teamId,
            senderId: senderId,
            senderName: senderName,
            content: message.content || '[Message not available]',
            timestamp: message.timestamp || new Date(),
            isSenderActive: message.sender?.isActive !== false,
          };
        } catch (error) {
          console.error('Error processing message:', error, message);
          // Return a safe message object
          return {
            id: message?._id?.toString() || 'unknown',
            teamId: teamId,
            senderId: 'unknown',
            senderName: 'Deleted User',
            content: '[Message could not be loaded]',
            timestamp: new Date(),
            isSenderActive: false,
          };
        }
      });

    return safeMessages;
  } catch (error: any) {
    console.error('getTeamMessages error:', error);
    // Return empty array instead of throwing 500 error
    return [];
  }
}

  @Post('cleanup-orphaned-messages')
  @UseGuards(JwtAuthGuard)
  async cleanupOrphanedMessages(@Body() body: { teamId?: string }) {
    try {
      const result = await this.chatService.cleanupOrphanedMessages(body.teamId);
      return {
        success: true,
        message: `Cleaned up ${result.deletedCount} orphaned messages`,
        deletedCount: result.deletedCount,
      };
    } catch (error: any) {
      return {
        success: false,
        message: 'Failed to cleanup orphaned messages',
        error: error.message,
      };
    }
  }
  @Post('cleanup-team-messages/:teamId')
@UseGuards(JwtAuthGuard)
async cleanupTeamMessages(@Param('teamId') teamId: string) {
  try {
    // First, try to get messages to see what's wrong
    const messages = await this.chatService.getTeamMessages(teamId);
    
    // Find problematic messages
    const problematicMessages = messages.filter((m: any) => {
      return !m || !m._id || !m.sender || !m.content;
    });
    
    this.logger.log(`Found ${problematicMessages.length} problematic messages for team ${teamId}`);
    
    // Delete problematic messages
    if (problematicMessages.length > 0) {
      const messageIds = problematicMessages.map((m: any) => m._id.toString());
      const result = await this.messageModel.deleteMany({
        _id: { $in: messageIds }
      }).exec();
      
      this.logger.log(`Deleted ${result.deletedCount} problematic messages`);
      
      return {
        success: true,
        message: `Found and deleted ${result.deletedCount} problematic messages`,
        deletedCount: result.deletedCount,
        teamId: teamId,
      };
    }
    
    return {
      success: true,
      message: 'No problematic messages found',
      deletedCount: 0,
      teamId: teamId,
    };
    
  } catch (error: any) {
    this.logger.error(`Cleanup error: ${error.message}`);
    return {
      success: false,
      message: 'Cleanup failed',
      error: error.message,
    };
  }
}
@Get('debug-team-messages/:teamId')
@UseGuards(JwtAuthGuard)
async debugTeamMessages(@Param('teamId') teamId: string) {
  try {
    const messages = await this.chatService.getTeamMessages(teamId) as any[];
    
    // Log each message to see which one is problematic
    const debugMessages = messages.map((m, index) => {
      console.log(`Message ${index}:`, {
        hasMessage: !!m,
        hasId: !!(m?._id),
        id: m?._id?.toString(),
        hasTeam: !!(m?.team),
        team: m?.team?.toString(),
        hasSender: !!(m?.sender),
        senderId: m?.sender?._id?.toString(),
        senderName: m?.sender?.name,
        content: m?.content?.substring(0, 50),
      });
      
      return {
        index,
        hasMessage: !!m,
        hasId: !!(m?._id),
        id: m?._id?.toString() || 'NO_ID',
        hasTeam: !!(m?.team),
        team: m?.team?.toString() || 'NO_TEAM',
        hasSender: !!(m?.sender),
        senderId: m?.sender?._id?.toString() || 'NO_SENDER_ID',
        senderName: m?.sender?.name || 'NO_SENDER_NAME',
        content: m?.content?.substring(0, 50) || 'NO_CONTENT',
      };
    });
    
    return {
      teamId,
      totalMessages: messages.length,
      messages: debugMessages,
    };
  } catch (error: any) {
    console.error('Debug error:', error);
    return {
      error: error.message,
      stack: error.stack,
    };
  }
}
}
