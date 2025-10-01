import { ChatService } from './chat.service';
export declare class ChatGateway {
    private readonly chatService;
    constructor(chatService: ChatService);
    handleJoinTeam(data: {
        teamId: string;
    }, client: any): Promise<void>;
    handleMessage(data: any, client: any): Promise<import("./schemas/message.schema").Message>;
}
