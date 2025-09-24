import { Connection } from 'mongoose';
export declare class AppController {
    private readonly connection;
    constructor(connection: Connection);
    getHealth(): {
        status: string;
        message: string;
        database: string;
        timestamp: string;
    };
    testDb(): Promise<{
        database: string;
        status: string;
        ping: import("bson").Document;
        error?: undefined;
    } | {
        database: string;
        status: string;
        error: any;
        ping?: undefined;
    }>;
}
