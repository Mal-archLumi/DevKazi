import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { GoogleLoginDto } from './dto/google-login.dto';
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
    healthCheck(): Promise<{
        status: string;
        service: string;
        timestamp: string;
        message: string;
    }>;
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
    googleLogin(googleLoginDto: GoogleLoginDto): Promise<{
        access_token: string;
        refresh_token: string;
        user: any;
    }>;
    getCurrentUser(req: any): Promise<{
        user: any;
    }>;
    refreshToken(refreshTokenDto: RefreshTokenDto): Promise<{
        access_token: string;
        refresh_token: string;
    }>;
    changePassword(req: any, changePasswordDto: ResetPasswordDto): Promise<{
        message: string;
    }>;
    forgotPassword(forgotPasswordDto: ForgotPasswordDto): Promise<{
        message: string;
    }>;
    resetPassword(resetPasswordDto: ResetPasswordDto): Promise<{
        message: string;
    }>;
    logout(req: any): Promise<{
        message: string;
    }>;
    validateToken(req: any): Promise<{
        user: any;
        valid: boolean;
    }>;
}
