import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Message } from './schemas/message.schema';

@Injectable()
export class ChatService {
  constructor(@InjectModel(Message.name) private messageModel: Model<Message>) {}

  async createMessage(createMessageDto: any): Promise<Message> {
    const message = new this.messageModel(createMessageDto);
    return message.save();
  }

  async getTeamMessages(teamId: string): Promise<Message[]> {
    return this.messageModel.find({ team: teamId })
      .populate('sender', 'name email')
      .sort({ createdAt: 1 })
      .limit(100);
  }
}