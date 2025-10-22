import { Model } from 'mongoose';
import { Message } from './schemas/message.schema';
export declare class ChatService {
    private messageModel;
    constructor(messageModel: Model<Message>);
    createMessage(createMessageDto: {
        team: string;
        sender: string;
        content: string;
    }): Promise<Message>;
    getTeamMessages(teamId: string, limit?: number): Promise<Message[]>;
    getRecentTeamMessages(teamId: string, limit?: number): Promise<Message[]>;
}
