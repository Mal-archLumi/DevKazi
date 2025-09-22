import { Model } from 'mongoose';
import { Message } from './schemas/message.schema';
export declare class ChatService {
    private messageModel;
    constructor(messageModel: Model<Message>);
    createMessage(createMessageDto: any): Promise<Message>;
    getTeamMessages(teamId: string): Promise<Message[]>;
}
