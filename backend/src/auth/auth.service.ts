import { Injectable, UnauthorizedException, ConflictException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { User, UserDocument } from '../modules/users/schemas/user.schema';
import * as bcrypt from 'bcrypt';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { Role } from './enums/role.enum';

@Injectable()
export class AuthService {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    private jwtService: JwtService,
  ) {}

  async register(registerDto: RegisterDto): Promise<{ 
    access_token: string; 
    refresh_token: string;
    user: any;
  }> {
    const { email, password, name, roles } = registerDto;

    // Validate input
    if (!email || !password || !name) {
      throw new BadRequestException('Email, password, and name are required');
    }

    // Check if user already exists
    const existingUser = await this.userModel.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      throw new ConflictException('User with this email already exists');
    }

    // Hash password with proper salt rounds
    const hashedPassword = await bcrypt.hash(password, 12);

    // Create user with proper role handling
    const userRoles = roles && roles.length > 0 ? roles : [Role.STUDENT];
    
    // Validate roles
    const validRoles = Object.values(Role);
    const invalidRoles = userRoles.filter(role => !validRoles.includes(role as Role));
    if (invalidRoles.length > 0) {
      throw new BadRequestException(`Invalid roles: ${invalidRoles.join(', ')}`);
    }

    const user = await this.userModel.create({
      email: email.toLowerCase(),
      password: hashedPassword,
      name: name.trim(),
      roles: userRoles,
      isVerified: false,
      isActive: true,
      isProfilePublic: true,
      skills: [],
      experienceYears: 0,
    });

    // Generate tokens - safely access _id
    const userId = this.getUserId(user);
    const tokens = await this.generateTokens(userId, user.roles);

    // Return user without sensitive data
    const userResponse = this.sanitizeUser(user);

    return {
      ...tokens,
      user: userResponse,
    };
  }

  async login(loginDto: LoginDto): Promise<{ 
    access_token: string; 
    refresh_token: string;
    user: any;
  }> {
    const { email, password } = loginDto;

    // Validate input
    if (!email || !password) {
      throw new BadRequestException('Email and password are required');
    }

    // Find user
    const user = await this.userModel.findOne({ email: email.toLowerCase() });
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Check if user is active
    if (user.isActive === false) {
      throw new UnauthorizedException('Account is deactivated. Please contact support.');
    }

    // Verify password with timing-safe comparison
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Generate tokens - safely access _id
    const userId = this.getUserId(user);
    const tokens = await this.generateTokens(userId, user.roles);

    // Return sanitized user
    const userResponse = this.sanitizeUser(user);

    return {
      ...tokens,
      user: userResponse,
    };
  }

  async refreshToken(refreshToken: string): Promise<{ 
    access_token: string; 
    refresh_token: string;
  }> {
    if (!refreshToken) {
      throw new UnauthorizedException('Refresh token is required');
    }

    try {
      const payload = await this.jwtService.verifyAsync(refreshToken, {
        secret: process.env.JWT_REFRESH_SECRET || 'fallback-refresh-secret',
      });

      const user = await this.userModel.findById(payload.sub);
      if (!user || !user.isActive) {
        throw new UnauthorizedException('Invalid refresh token');
      }

      // Check if user needs to re-authenticate (e.g., after password change)
      const tokenIssuedAt = payload.iat * 1000;
      
      // Safely access updatedAt
      const userUpdatedAt = this.getUpdatedAt(user);
      if (userUpdatedAt && userUpdatedAt.getTime() > tokenIssuedAt) {
        throw new UnauthorizedException('Session expired. Please login again.');
      }

      const userId = this.getUserId(user);
      return this.generateTokens(userId, user.roles);
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        throw new UnauthorizedException('Refresh token expired');
      }
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  async validateUser(payload: any): Promise<any> {
    if (!payload || !payload.sub) {
      return null;
    }

    const user = await this.userModel.findById(payload.sub);
    if (!user || !user.isActive) {
      return null;
    }

    return this.sanitizeUser(user);
  }

  async validateToken(token: string): Promise<any> {
    if (!token) {
      throw new UnauthorizedException('Token is required');
    }

    try {
      const payload = await this.jwtService.verifyAsync(token, {
        secret: process.env.JWT_SECRET || 'fallback-secret',
      });
      
      return this.validateUser(payload);
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        throw new UnauthorizedException('Token expired');
      }
      throw new UnauthorizedException('Invalid token');
    }
  }

  async logout(userId: string): Promise<{ message: string }> {
    console.log(`User ${userId} logged out`);
    return { message: 'Logged out successfully' };
  }

  async changePassword(userId: string, currentPassword: string, newPassword: string): Promise<{ message: string }> {
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    // Verify current password
    const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.password);
    if (!isCurrentPasswordValid) {
      throw new UnauthorizedException('Current password is incorrect');
    }

    // Hash new password
    const hashedNewPassword = await bcrypt.hash(newPassword, 12);

    // Update password and set updatedAt
    await this.userModel.findByIdAndUpdate(userId, {
      password: hashedNewPassword,
      updatedAt: new Date(),
    });

    return { message: 'Password changed successfully' };
  }

  private async generateTokens(userId: string, roles: string[]): Promise<{ 
    access_token: string; 
    refresh_token: string;
  }> {
    const payload = { 
      sub: userId, 
      roles: roles,
      email: await this.getUserEmail(userId),
      iat: Math.floor(Date.now() / 1000),
    };

    const access_token = await this.jwtService.signAsync(payload, {
      expiresIn: process.env.JWT_EXPIRES_IN || '15m',
      secret: process.env.JWT_SECRET || 'fallback-secret',
    });

    const refresh_token = await this.jwtService.signAsync(payload, {
      expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
      secret: process.env.JWT_REFRESH_SECRET || 'fallback-refresh-secret',
    });

    return { access_token, refresh_token };
  }

  private async getUserEmail(userId: string): Promise<string> {
    const user = await this.userModel.findById(userId);
    return user?.email || '';
  }

  private sanitizeUser(user: UserDocument): any {
    const userObj = user.toObject ? user.toObject() : user;
    const { password, ...userWithoutPassword } = userObj;
    return userWithoutPassword;
  }

  // Safe method to get user ID with proper type handling
  private getUserId(user: UserDocument): string {
    // Use type assertion to safely access _id
    const userObj = user as any;
    if (userObj._id && userObj._id.toString) {
      return userObj._id.toString();
    }
    if (userObj.id) {
      return userObj.id;
    }
    throw new Error('Unable to get user ID');
  }

  // Safe method to get updatedAt with proper type handling
  private getUpdatedAt(user: UserDocument): Date | null {
    // Use type assertion to safely access updatedAt
    const userObj = user as any;
    return userObj.updatedAt || null;
  }
}