import { ConfigService } from '@nestjs/config';
import { Model } from 'mongoose';
import { User } from '../../modules/users/schemas/user.schema';
declare const JwtStrategy_base: new (...args: any[]) => any;
export declare class JwtStrategy extends JwtStrategy_base {
    private configService;
    private userModel;
    private readonly logger;
    constructor(configService: ConfigService, userModel: Model<User>);
    validate(payload: any): Promise<{
        userId: string;
        email: string;
        name: string;
        isVerified: boolean;
    }>;
}
export {};
