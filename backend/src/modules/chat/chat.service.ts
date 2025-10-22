import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Message } from './schemas/message.schema';

@Injectable()
export class ChatService {
  constructor(@InjectModel(Message.name) private messageModel: Model<Message>) {}

  async createMessage(createMessageDto: { 
    team: string; 
    sender: string; 
    content: string;
  }): Promise<Message> {
    // Validate input
    if (!createMessageDto.team || !createMessageDto.sender || !createMessageDto.content) {
      throw new BadRequestException('Team, sender, and content are required');
    }

    if (createMessageDto.content.trim().length === 0) {
      throw new BadRequestException('Message content cannot be empty');
    }

    if (createMessageDto.content.length > 1000) {
      throw new BadRequestException('Message too long (max 1000 characters)');
    }

    const message = new this.messageModel({
      team: new Types.ObjectId(createMessageDto.team),
      sender: new Types.ObjectId(createMessageDto.sender),
      content: createMessageDto.content.trim(),
      timestamp: new Date(),
    });

    return message.save();
  }

  async getTeamMessages(teamId: string, limit: number = 100): Promise<Message[]> {
    if (!Types.ObjectId.isValid(teamId)) {
      throw new BadRequestException('Invalid team ID');
    }

    return this.messageModel
      .find({ team: new Types.ObjectId(teamId) })
      .populate('sender', 'name email') // Only get name and email from user
      .sort({ timestamp: 1 }) // Oldest first
      .limit(limit)
      .exec();
  }

  async getRecentTeamMessages(teamId: string, limit: number = 50): Promise<Message[]> {
    if (!Types.ObjectId.isValid(teamId)) {
      throw new BadRequestException('Invalid team ID');
    }

    return this.messageModel
      .find({ team: new Types.ObjectId(teamId) })
      .populate('sender', 'name email')
      .sort({ timestamp: -1 }) // Newest first
      .limit(limit)
      .exec();
  }
}