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
        usersCount: number;
        collections: string[];
        error?: undefined;
    } | {
        database: string;
        status: string;
        error: any;
        usersCount?: undefined;
        collections?: undefined;
    }>;
}
