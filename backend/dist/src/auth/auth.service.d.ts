import { JwtService } from '@nestjs/jwt';
import { Model } from 'mongoose';
import { UserDocument } from '../modules/users/schemas/user.schema';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
export declare class AuthService {
    private userModel;
    private jwtService;
    private googleClient;
    private readonly logger;
    constructor(userModel: Model<UserDocument>, jwtService: JwtService);
    register(registerDto: RegisterDto): Promise<{
        access_token: string;
        refresh_token: string;
        user: any;
    }>;
    login(loginDto: LoginDto): Promise<{
        access_token: string;
        refresh_token: string;
        user: any;
    }>;
    googleLogin(idToken: string): Promise<{
        access_token: string;
        refresh_token: string;
        user: any;
    }>;
    refreshToken(refreshToken: string): Promise<{
        access_token: string;
        refresh_token: string;
    }>;
    validateUser(payload: any): Promise<any>;
    validateToken(token: string): Promise<any>;
    logout(userId: string): Promise<{
        message: string;
    }>;
    changePassword(userId: string, currentPassword: string, newPassword: string): Promise<{
        message: string;
    }>;
    forgotPassword(email: string): Promise<{
        message: string;
    }>;
    resetPassword(token: string, newPassword: string): Promise<{
        message: string;
    }>;
    private generateTokens;
    private sanitizeUser;
    private getUserId;
    private getUpdatedAt;
    private parseExpiresIn;
}
