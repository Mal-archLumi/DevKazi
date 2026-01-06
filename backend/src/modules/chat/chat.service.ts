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

  async getTeamMessages(teamId: string, limit: number = 100): Promise<Message[]> {
    if (!this.isValidObjectId(teamId)) {
      throw new BadRequestException('Invalid team ID');
    }

    return this.messageModel
      .find({ team: teamId })
      .populate('sender', 'name email username firstName lastName')
      .sort({ timestamp: 1 })
      .limit(limit)
      .exec();
  }

  async getMessageById(messageId: string): Promise<Message | null> {
    if (!this.isValidObjectId(messageId)) {
      throw new BadRequestException('Invalid message ID');
    }

    return this.messageModel
      .findById(messageId)
      .populate('sender', 'name email username firstName lastName')
      .exec();
  }

  async deleteMessages(messageIds: string[]): Promise<{ deletedCount: number }> {
    if (!messageIds || messageIds.length === 0) {
      throw new BadRequestException('Message IDs are required');
    }

    // FIX: Use parentheses (), not backticks ``
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

  private isValidObjectId(id: string): boolean {
    return mongoose.isValidObjectId(id);
  }
}