import { OnGatewayConnection, OnGatewayDisconnect } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { ChatService } from './chat.service';
export declare class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
    private readonly chatService;
    server: Server;
    constructor(chatService: ChatService);
    handleConnection(client: Socket): Promise<void>;
    handleDisconnect(client: Socket): Promise<void>;
    handleJoinTeam(data: {
        teamId: string;
    }, client: Socket): Promise<void>;
    handleMessage(data: {
        team: string;
        sender: string;
        content: string;
    }, client: Socket): Promise<{
        success: boolean;
        message: import("./schemas/message.schema").Message;
        error?: undefined;
    } | {
        success: boolean;
        error: any;
        message?: undefined;
    }>;
    handleGetTeamMessages(data: {
        teamId: string;
    }, client: Socket): Promise<{
        success: boolean;
        messages: import("./schemas/message.schema").Message[];
        error?: undefined;
    } | {
        success: boolean;
        error: any;
        messages?: undefined;
    }>;
}
