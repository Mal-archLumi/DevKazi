// chat.service.ts
import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import * as mongoose from 'mongoose';
import { Model, Types } from 'mongoose';
import { Message } from './schemas/message.schema';

@Injectable()
export class ChatService {
  constructor(@InjectModel(Message.name) private messageModel: Model<Message>) {}

  // FIXED: Use string directly since Mongoose handles ObjectId conversion
  async saveMessage(data: { teamId: string; senderId: string; content: string }): Promise<Message> {
    if (!data.teamId || !data.senderId || !data.content?.trim()) {
      throw new BadRequestException('teamId, senderId, and content are required');
    }

    // FIX: Use Types.ObjectId.isValid correctly
    if (!this.isValidObjectId(data.teamId) || !this.isValidObjectId(data.senderId)) {
      throw new BadRequestException('Invalid teamId or senderId');
    }

    const message = new this.messageModel({
      team: data.teamId, // Mongoose automatically converts to ObjectId
      sender: data.senderId, // Mongoose automatically converts to ObjectId
      content: data.content.trim(),
      timestamp: new Date(),
    });

    return await message.save();
  }

  async createMessage(createMessageDto: { 
    team: string; 
    sender: string; 
    content: string;
  }): Promise<Message> {
    if (!createMessageDto.team || !createMessageDto.sender || !createMessageDto.content) {
      throw new BadRequestException('Team, sender, and content are required');
    }

    if (createMessageDto.content.trim().length === 0) {
      throw new BadRequestException('Message content cannot be empty');
    }

    if (createMessageDto.content.length > 1000) {
      throw new BadRequestException('Message too long (max 1000 characters)');
    }

    // FIX: Use Types.ObjectId.isValid correctly
    if (!this.isValidObjectId(createMessageDto.team) || !this.isValidObjectId(createMessageDto.sender)) {
      throw new BadRequestException('Invalid team or sender ID');
    }

    const message = new this.messageModel({
      team: createMessageDto.team, // Mongoose handles conversion
      sender: createMessageDto.sender, // Mongoose handles conversion
      content: createMessageDto.content.trim(),
      timestamp: new Date(),
    });

    return message.save();
  }

  async getTeamMessages(teamId: string, limit: number = 100): Promise<Message[]> {
    // FIX: Use Types.ObjectId.isValid correctly
    if (!this.isValidObjectId(teamId)) {
      throw new BadRequestException('Invalid team ID');
    }

    return this.messageModel
      .find({ team: teamId }) // Mongoose handles ObjectId conversion
      .populate('sender', 'name email username firstName lastName')
      .sort({ timestamp: 1 })
      .limit(limit)
      .exec();
  }

  async getRecentTeamMessages(teamId: string, limit: number = 50): Promise<Message[]> {
    // FIX: Use Types.ObjectId.isValid correctly
    if (!this.isValidObjectId(teamId)) {
      throw new BadRequestException('Invalid team ID');
    }

    return this.messageModel
      .find({ team: teamId }) // Mongoose handles ObjectId conversion
      .populate('sender', 'name email')
      .sort({ timestamp: -1 })
      .limit(limit)
      .exec();
  }

  async getMessageWithSender(messageId: Types.ObjectId): Promise<Message | null> {
    return this.messageModel
      .findById(messageId)
      .populate('sender', 'name email username firstName lastName')
      .exec();
  }
  // FIX: Helper method to check ObjectId validity
  private isValidObjectId(id: string): boolean {
    return mongoose.isValidObjectId(id);
  }
  }