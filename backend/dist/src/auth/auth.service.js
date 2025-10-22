"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
var AuthService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
const user_schema_1 = require("../modules/users/schemas/user.schema");
const bcrypt = __importStar(require("bcrypt"));
const google_auth_library_1 = require("google-auth-library");
let AuthService = AuthService_1 = class AuthService {
    userModel;
    jwtService;
    googleClient;
    logger = new common_1.Logger(AuthService_1.name);
    constructor(userModel, jwtService) {
        this.userModel = userModel;
        this.jwtService = jwtService;
        this.googleClient = new google_auth_library_1.OAuth2Client(process.env.GOOGLE_WEB_CLIENT_ID);
    }
    async register(registerDto) {
        const { email, password, name, skills } = registerDto;
        if (!email || !password || !name) {
            throw new common_1.BadRequestException('Email, password, and name are required');
        }
        const existingUser = await this.userModel.findOne({ email: email.toLowerCase() });
        if (existingUser) {
            throw new common_1.ConflictException('User with this email already exists');
        }
        const hashedPassword = await bcrypt.hash(password, 12);
        const user = await this.userModel.create({
            email: email.toLowerCase(),
            password: hashedPassword,
            name: name.trim(),
            skills: skills || [],
            isVerified: false,
            isActive: true,
        });
        const userId = this.getUserId(user);
        const tokens = await this.generateTokens(userId);
        const userResponse = this.sanitizeUser(user);
        return {
            ...tokens,
            user: userResponse,
        };
    }
    async login(loginDto) {
        const { email, password } = loginDto;
        if (!email || !password) {
            throw new common_1.BadRequestException('Email and password are required');
        }
        const user = await this.userModel.findOne({ email: email.toLowerCase() });
        if (!user) {
            throw new common_1.UnauthorizedException('Invalid credentials');
        }
        if (user.isActive === false) {
            throw new common_1.UnauthorizedException('Account is deactivated. Please contact support.');
        }
        if (!user.password) {
            throw new common_1.UnauthorizedException('Please use Google Sign-In for this account');
        }
        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) {
            throw new common_1.UnauthorizedException('Invalid credentials');
        }
        const userId = this.getUserId(user);
        const tokens = await this.generateTokens(userId);
        const userResponse = this.sanitizeUser(user);
        return {
            ...tokens,
            user: userResponse,
        };
    }
    async googleLogin(idToken) {
        this.logger.log('Starting Google login process');
        if (!idToken) {
            this.logger.error('Google ID token is required');
            throw new common_1.BadRequestException('Google ID token is required');
        }
        try {
            this.logger.log('Verifying Google ID token');
            const ticket = await this.googleClient.verifyIdToken({
                idToken,
                audience: process.env.GOOGLE_WEB_CLIENT_ID,
            });
            const payload = ticket.getPayload();
            if (!payload) {
                this.logger.error('Invalid Google token - no payload');
                throw new common_1.UnauthorizedException('Invalid Google token');
            }
            this.logger.log(`Google token verified for email: ${payload.email}`);
            const { sub: googleId, email, name, given_name, family_name, picture } = payload;
            if (!email) {
                this.logger.error('Email not provided by Google');
                throw new common_1.UnauthorizedException('Email not provided by Google');
            }
            const userName = name || given_name || family_name || email.split('@')[0] || 'Google User';
            this.logger.log(`Processing user: ${email}, name: ${userName}`);
            let user = await this.userModel.findOne({ googleId });
            if (!user) {
                this.logger.log(`No user found with googleId: ${googleId}, checking by email: ${email}`);
                user = await this.userModel.findOne({ email: email.toLowerCase() });
                if (user) {
                    this.logger.log(`Found existing user by email: ${email}, linking Google account`);
                    user.googleId = googleId;
                    user.picture = picture || user.picture;
                    user.name = userName;
                    await user.save();
                }
                else {
                    this.logger.log(`Creating new user for Google login: ${email}`);
                    user = await this.userModel.create({
                        googleId,
                        email: email.toLowerCase(),
                        name: userName,
                        picture,
                        isVerified: true,
                        isActive: true,
                        skills: [],
                    });
                }
            }
            else {
                this.logger.log(`Found existing user with googleId: ${googleId}`);
            }
            if (!user.isActive) {
                this.logger.error(`User account is deactivated: ${email}`);
                throw new common_1.UnauthorizedException('Account is deactivated. Please contact support.');
            }
            const userId = this.getUserId(user);
            this.logger.log(`Generating tokens for user ID: ${userId}`);
            const tokens = await this.generateTokens(userId);
            const userResponse = this.sanitizeUser(user);
            this.logger.log(`Google login successful for user: ${email}`);
            return {
                ...tokens,
                user: userResponse,
            };
        }
        catch (error) {
            this.logger.error(`Google login failed: ${error.message}`, error.stack);
            if (error instanceof common_1.UnauthorizedException || error instanceof common_1.BadRequestException) {
                throw error;
            }
            throw new common_1.UnauthorizedException('Google authentication failed');
        }
    }
    async refreshToken(refreshToken) {
        if (!refreshToken) {
            throw new common_1.UnauthorizedException('Refresh token is required');
        }
        try {
            const payload = await this.jwtService.verifyAsync(refreshToken, {
                secret: process.env.JWT_REFRESH_SECRET || 'fallback-refresh-secret',
            });
            const user = await this.userModel.findById(payload.sub);
            if (!user || !user.isActive) {
                throw new common_1.UnauthorizedException('Invalid refresh token');
            }
            const tokenIssuedAt = payload.iat * 1000;
            const userUpdatedAt = this.getUpdatedAt(user);
            if (userUpdatedAt && userUpdatedAt.getTime() > tokenIssuedAt) {
                throw new common_1.UnauthorizedException('Session expired. Please login again.');
            }
            const userId = this.getUserId(user);
            return this.generateTokens(userId);
        }
        catch (error) {
            if (error.name === 'TokenExpiredError') {
                throw new common_1.UnauthorizedException('Refresh token expired');
            }
            throw new common_1.UnauthorizedException('Invalid refresh token');
        }
    }
    async validateUser(payload) {
        if (!payload || !payload.sub) {
            return null;
        }
        const user = await this.userModel.findById(payload.sub);
        if (!user || !user.isActive) {
            return null;
        }
        return this.sanitizeUser(user);
    }
    async validateToken(token) {
        if (!token) {
            throw new common_1.UnauthorizedException('Token is required');
        }
        try {
            const payload = await this.jwtService.verifyAsync(token, {
                secret: process.env.JWT_SECRET || 'fallback-secret',
            });
            return this.validateUser(payload);
        }
        catch (error) {
            if (error.name === 'TokenExpiredError') {
                throw new common_1.UnauthorizedException('Token expired');
            }
            throw new common_1.UnauthorizedException('Invalid token');
        }
    }
    async logout(userId) {
        console.log(`User ${userId} logged out`);
        return { message: 'Logged out successfully' };
    }
    async changePassword(userId, currentPassword, newPassword) {
        const user = await this.userModel.findById(userId);
        if (!user) {
            throw new common_1.UnauthorizedException('User not found');
        }
        if (!user.password) {
            throw new common_1.UnauthorizedException('Google users cannot change password. Please set a password first.');
        }
        const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.password);
        if (!isCurrentPasswordValid) {
            throw new common_1.UnauthorizedException('Current password is incorrect');
        }
        const hashedNewPassword = await bcrypt.hash(newPassword, 12);
        await this.userModel.findByIdAndUpdate(userId, {
            password: hashedNewPassword,
            updatedAt: new Date(),
        });
        return { message: 'Password changed successfully' };
    }
    async forgotPassword(email) {
        if (!email) {
            throw new common_1.BadRequestException('Email is required');
        }
        const user = await this.userModel.findOne({ email: email.toLowerCase() });
        if (!user) {
            throw new common_1.BadRequestException('User with this email does not exist');
        }
        if (!user.password) {
            throw new common_1.BadRequestException('Google users cannot reset password. Please use Google Sign-In.');
        }
        return { message: 'Password reset link sent to your email' };
    }
    async resetPassword(token, newPassword) {
        throw new Error('Method not implemented.');
    }
    async generateTokens(userId) {
        const payload = {
            sub: userId,
        };
        const access_token = await this.jwtService.signAsync(payload, {
            expiresIn: process.env.JWT_EXPIRES_IN ? this.parseExpiresIn(process.env.JWT_EXPIRES_IN) : 15 * 60,
            secret: process.env.JWT_SECRET || 'fallback-secret',
        });
        const refresh_token = await this.jwtService.signAsync(payload, {
            expiresIn: process.env.JWT_REFRESH_EXPIRES_IN ? this.parseExpiresIn(process.env.JWT_REFRESH_EXPIRES_IN) : 7 * 24 * 60 * 60,
            secret: process.env.JWT_REFRESH_SECRET || 'fallback-refresh-secret',
        });
        return { access_token, refresh_token };
    }
    sanitizeUser(user) {
        const userObj = user.toObject ? user.toObject() : user;
        const { password, ...userWithoutPassword } = userObj;
        return userWithoutPassword;
    }
    getUserId(user) {
        const userObj = user;
        if (userObj._id && userObj._id.toString) {
            return userObj._id.toString();
        }
        if (userObj.id) {
            return userObj.id;
        }
        throw new Error('Unable to get user ID');
    }
    getUpdatedAt(user) {
        const userObj = user;
        return userObj.updatedAt || null;
    }
    parseExpiresIn(expiresIn) {
        const match = expiresIn.match(/^(\d+)([smhd])$/);
        if (!match) {
            throw new Error(`Invalid expiresIn format: ${expiresIn}`);
        }
        const value = parseInt(match[1], 10);
        const unit = match[2];
        switch (unit) {
            case 's': return value;
            case 'm': return value * 60;
            case 'h': return value * 60 * 60;
            case 'd': return value * 60 * 60 * 24;
            default: throw new Error(`Unknown unit: ${unit}`);
        }
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = AuthService_1 = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, mongoose_1.InjectModel)(user_schema_1.User.name)),
    __metadata("design:paramtypes", [mongoose_2.Model,
        jwt_1.JwtService])
], AuthService);
//# sourceMappingURL=auth.service.js.map