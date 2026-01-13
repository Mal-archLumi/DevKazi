// chat.service.ts
import { Injectable, BadRequestException, NotFoundException, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import * as mongoose from 'mongoose';
import { Model, Types } from 'mongoose';
import { Message } from './schemas/message.schema';

@Injectable()
export class ChatService {
  private readonly logger = new Logger(ChatService.name);

  constructor(@InjectModel(Message.name) private messageModel: Model<Message>) {}

  async saveMessage(data: { 
    teamId: string; 
    senderId: string; 
    content: string;
    replyToId?: string;
  }): Promise<Message> {
    if (!data.teamId || !data.senderId || !data.content?.trim()) {
      throw new BadRequestException('teamId, senderId, and content are required');
    }

    if (!this.isValidObjectId(data.teamId) || !this.isValidObjectId(data.senderId)) {
      throw new BadRequestException('Invalid teamId or senderId');
    }

    if (data.replyToId && !this.isValidObjectId(data.replyToId)) {
      throw new BadRequestException('Invalid replyToId');
    }

    const messageData: any = {
      team: data.teamId,
      sender: data.senderId,
      content: data.content.trim(),
      timestamp: new Date(),
    };

    if (data.replyToId) {
      messageData.replyTo = data.replyToId;
    }

    const message = new this.messageModel(messageData);
    return await message.save();
  }

  async getTeamMessages(teamId: string, limit: number = 100): Promise<any[]> {
  if (!this.isValidObjectId(teamId)) {
    throw new BadRequestException('Invalid team ID');
  }

  try {
    const messages = await this.messageModel
      .find({ 
        $or: [
          { team: teamId },
          { team: new Types.ObjectId(teamId) }
        ]
      })
      .populate({
        path: 'sender',
        select: 'name email isActive',
        // This ensures we still get the document even if isActive is false
        match: { /* no match filter - get all */ }
      })
      .sort({ timestamp: 1 })
      .limit(limit)
      .lean()
      .exec();

    // Process messages to handle deleted/inactive users
    const processedMessages = messages.map(message => {
      // If sender doesn't exist or is inactive, create a placeholder
      if (!message.sender || (message.sender as any).isActive === false) {
        return {
          ...message,
          sender: {
            _id: message.sender?._id || new Types.ObjectId(),
            name: 'Deleted User',
            email: 'deleted@example.com',
            isActive: false
          }
        };
      }
      
      return message;
    });

    this.logger.log(`Returned ${processedMessages.length} messages for team ${teamId}`);
    return processedMessages;
  } catch (error: any) {
    this.logger.error(`Error fetching messages for team ${teamId}: ${error.message}`);
    throw error;
  }
}

  async getMessageById(messageId: string): Promise<Message | null> {
    if (!this.isValidObjectId(messageId)) {
      throw new BadRequestException('Invalid message ID');
    }

    return this.messageModel
      .findById(messageId)
      .populate('sender', 'name email username firstName lastName _id')
      .exec();
  }

  async deleteMessages(messageIds: string[]): Promise<{ deletedCount: number }> {
    if (!messageIds || messageIds.length === 0) {
      throw new BadRequestException('Message IDs are required');
    }

    this.logger.log(`🗑️ Attempting to delete ${messageIds.length} messages`);
    this.logger.log(`🗑️ Message IDs: ${messageIds.join(', ')}`);

    const invalidIds = messageIds.filter(id => !this.isValidObjectId(id));
    if (invalidIds.length > 0) {
      this.logger.error(`❌ Invalid message IDs: ${invalidIds.join(', ')}`);
      throw new BadRequestException(`Invalid message IDs: ${invalidIds.join(', ')}`);
    }

    try {
      const result = await this.messageModel.deleteMany({
        _id: { $in: messageIds }
      }).exec();

      this.logger.log(`✅ Database delete completed: ${result.deletedCount} of ${messageIds.length} messages deleted`);

      if (result.deletedCount === 0) {
        this.logger.warn('⚠️ No messages were deleted - they may not exist');
        throw new NotFoundException('No messages found to delete');
      }

      if (result.deletedCount !== messageIds.length) {
        this.logger.warn(`⚠️ Partial delete: ${result.deletedCount} of ${messageIds.length} deleted`);
      }

      return { deletedCount: result.deletedCount };
    } catch (error: any) {
      this.logger.error(`❌ Database delete error: ${error.message}`);
      this.logger.error(`Stack: ${error.stack}`);
      throw error;
    }
  }

  async getMessagesByIds(messageIds: string[]): Promise<Message[]> {
    if (!messageIds || messageIds.length === 0) {
      return [];
    }

    const invalidIds = messageIds.filter(id => !this.isValidObjectId(id));
    if (invalidIds.length > 0) {
      this.logger.error(`❌ Invalid message IDs: ${invalidIds.join(', ')}`);
      throw new BadRequestException(`Invalid message IDs: ${invalidIds.join(', ')}`);
    }

    return this.messageModel
      .find({ _id: { $in: messageIds } })
      .populate('sender', '_id name email')
      .exec();
  }

  // NEW METHOD: Clean up orphaned messages (messages with null senders)
  async cleanupOrphanedMessages(teamId?: string): Promise<{ deletedCount: number }> {
    try {
      const query: any = { sender: null };
      if (teamId) {
        query.team = teamId;
      }

      const result = await this.messageModel.deleteMany(query).exec();
      
      this.logger.log(`🧹 Cleaned up ${result.deletedCount} orphaned messages${teamId ? ` for team ${teamId}` : ''}`);
      
      return { deletedCount: result.deletedCount };
    } catch (error) {
      this.logger.error(`❌ Error cleaning up orphaned messages: ${error.message}`);
      throw error;
    }
  }

  private isValidObjectId(id: string): boolean {
    return mongoose.isValidObjectId(id);
  }
}