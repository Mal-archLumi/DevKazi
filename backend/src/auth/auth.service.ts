// src/auth/auth.service.ts
import { Injectable, UnauthorizedException, ConflictException, BadRequestException, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from '../modules/users/schemas/user.schema';
import * as bcryptjs from 'bcryptjs';
import * as nodemailer from 'nodemailer';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { ConfigService } from '@nestjs/config';
import { OAuth2Client } from 'google-auth-library';

@Injectable()
export class AuthService {
  private googleClient: OAuth2Client;
  private readonly logger = new Logger(AuthService.name);

  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {
    this.googleClient = new OAuth2Client(process.env.GOOGLE_WEB_CLIENT_ID);
  }

  async register(registerDto: RegisterDto): Promise<{ 
    access_token: string; 
    refresh_token: string;
    user: any;
  }> {
    const { email, password, name, skills } = registerDto;

    // Validate input
    if (!email || !password || !name) {
      throw new BadRequestException('Email, password, and name are required');
    }

    // Check if user already exists
    const existingUser = await this.userModel.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      throw new ConflictException('User with this email already exists');
    }

    // Hash password
    const hashedPassword = await bcryptjs.hash(password, 12);

    // Create user
    const user = await this.userModel.create({
      email: email.toLowerCase(),
      password: hashedPassword,
      name: name.trim(),
      skills: skills || [],
      isVerified: false,
      isActive: true,
    });

    // Generate tokens with enhanced payload
    const tokens = await this.generateTokens(user);

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

    // Check if user has a password (Google users don't have passwords)
    if (!user.password) {
      throw new UnauthorizedException('Please use Google Sign-In for this account');
    }

    // Verify password
    const isPasswordValid = await bcryptjs.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Generate tokens with enhanced payload
    const tokens = await this.generateTokens(user);

    // Return sanitized user
    const userResponse = this.sanitizeUser(user);

    return {
      ...tokens,
      user: userResponse,
    };
  }

  async googleLogin(idToken: string): Promise<{
    access_token: string;
    refresh_token: string;
    user: any;
  }> {
    this.logger.log('Starting Google login process');
    
    if (!idToken) {
      this.logger.error('Google ID token is required');
      throw new BadRequestException('Google ID token is required');
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
        throw new UnauthorizedException('Invalid Google token');
      }

      this.logger.log(`Google token verified for email: ${payload.email}`);
      
      const { sub: googleId, email, name, given_name, family_name, picture } = payload;

      if (!email) {
        this.logger.error('Email not provided by Google');
        throw new UnauthorizedException('Email not provided by Google');
      }

      // Handle missing name from Google
      const userName = name || given_name || family_name || email.split('@')[0] || 'Google User';
      
      this.logger.log(`Processing user: ${email}, name: ${userName}`);

      // Find or create user
      let user = await this.userModel.findOne({ googleId });
      
      if (!user) {
        this.logger.log(`No user found with googleId: ${googleId}, checking by email: ${email}`);
        user = await this.userModel.findOne({ email: email.toLowerCase() });
        
        if (user) {
          this.logger.log(`Found existing user by email: ${email}, linking Google account`);
          // Link Google ID to existing user
          user.googleId = googleId;
          user.picture = picture || user.picture;
          user.name = userName;
          await user.save();
        } else {
          this.logger.log(`Creating new user for Google login: ${email}`);
          // Create new user - Google users don't get passwords
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
      } else {
        this.logger.log(`Found existing user with googleId: ${googleId}`);
      }

      // Check if user is active
      if (!user.isActive) {
        this.logger.error(`User account is deactivated: ${email}`);
        throw new UnauthorizedException('Account is deactivated. Please contact support.');
      }

      // Generate tokens with enhanced payload
      this.logger.log(`Generating tokens for user ID: ${user._id}`);
      
      const tokens = await this.generateTokens(user);

      // Return sanitized user
      const userResponse = this.sanitizeUser(user);
      
      this.logger.log(`Google login successful for user: ${email}`);
      
      return {
        ...tokens,
        user: userResponse,
      };
    } catch (error) {
      this.logger.error(`Google login failed: ${error.message}`, error.stack);
      
      if (error instanceof UnauthorizedException || error instanceof BadRequestException) {
        throw error;
      }
      
      throw new UnauthorizedException('Google authentication failed');
    }
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

      // Check if user needs to re-authenticate
      const tokenIssuedAt = payload.iat * 1000;
      const userUpdatedAt = user.updatedAt;
      if (userUpdatedAt && userUpdatedAt.getTime() > tokenIssuedAt) {
        throw new UnauthorizedException('Session expired. Please login again.');
      }

      return this.generateTokens(user);
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
    this.logger.log(`User ${userId} logged out`);
    return { message: 'Logged out successfully' };
  }

  async changePassword(userId: string, currentPassword: string, newPassword: string): Promise<{ message: string }> {
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    // Check if user has a password
    if (!user.password) {
      throw new UnauthorizedException('Google users cannot change password. Please set a password first.');
    }

    // Verify current password
    const isCurrentPasswordValid = await bcryptjs.compare(currentPassword, user.password);
    if (!isCurrentPasswordValid) {
      throw new UnauthorizedException('Current password is incorrect');
    }

    // Hash new password
    const hashedNewPassword = await bcryptjs.hash(newPassword, 12);

    // Update password
    await this.userModel.findByIdAndUpdate(userId, {
      password: hashedNewPassword,
      updatedAt: new Date(),
    });

    return { message: 'Password changed successfully' };
  }

  async forgotPassword(email: string): Promise<{ message: string }> {
    if (!email) {
      throw new BadRequestException('Email is required');
    }
    
    const user = await this.userModel.findOne({ email: email.toLowerCase() });
    if (!user) {
      throw new BadRequestException('User with this email does not exist');
    }

    // Check if user has a password
    if (!user.password) {
      throw new BadRequestException('Google users cannot reset password. Please use Google Sign-In.');
    }

    // Generate reset token
    const resetToken = await this.jwtService.signAsync(
      { sub: user._id.toString(), type: 'reset' },
      { secret: process.env.JWT_SECRET || 'fallback-secret', expiresIn: '1h' }
    );

    // Send email with nodemailer
    const transporter = nodemailer.createTransport({
      host: this.configService.get<string>('SMTP_HOST'),
      port: this.configService.get<number>('SMTP_PORT') || 587,
      secure: this.configService.get<number>('SMTP_PORT') === 465,
      auth: {
        user: this.configService.get<string>('SMTP_USER'),
        pass: this.configService.get<string>('SMTP_PASS'),
      },
    });

    const mailOptions = {
      from: this.configService.get<string>('MAIL_FROM') || '"DevKazi" <no-reply@devkazi.com>',
      to: email,
      subject: 'Password Reset Request',
      text: `Click this link to reset your password: ${this.configService.get<string>('FRONTEND_URL')}/reset-password?token=${resetToken}`,
    };

    await transporter.sendMail(mailOptions);

    return { message: 'Password reset link sent to your email' };
  }

  async resetPassword(token: string, newPassword: string): Promise<{ message: string }> {
    if (!token || !newPassword) {
      throw new BadRequestException('Token and new password are required');
    }

    try {
      // Verify reset token
      const payload = await this.jwtService.verifyAsync(token, {
        secret: process.env.JWT_SECRET || 'fallback-secret',
      });

      if (payload.type !== 'reset') {
        throw new UnauthorizedException('Invalid reset token');
      }

      const user = await this.userModel.findById(payload.sub);
      if (!user) {
        throw new BadRequestException('User not found');
      }

      // Check if user has a password
      if (!user.password) {
        throw new BadRequestException('Google users cannot reset password. Please use Google Sign-In.');
      }

      // Hash new password
      const hashedPassword = await bcryptjs.hash(newPassword, 12);

      // Update password
      await this.userModel.findByIdAndUpdate(payload.sub, {
        password: hashedPassword,
        updatedAt: new Date(),
      });

      return { message: 'Password reset successfully' };
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        throw new UnauthorizedException('Reset token expired');
      }
      throw new UnauthorizedException('Invalid reset token');
    }
  }

  private async generateTokens(user: UserDocument): Promise<{
    access_token: string;
    refresh_token: string;
  }> {
    // Enhanced JWT payload with user data
    const payload = {
      sub: user._id.toString(),        // Required
      userId: user._id.toString(),     // Additional identifier
      email: user.email,               // User email
      name: user.name,                 // User name
      isVerified: user.isVerified,     // Verification status
      // ... add other user data as needed
    };

    const access_token = await this.jwtService.signAsync(payload, {
      expiresIn: process.env.JWT_EXPIRES_IN || '15m',
      secret: process.env.JWT_SECRET || 'fallback-secret',
    });

    const refresh_token = await this.jwtService.signAsync(
      { sub: user._id.toString() }, // Simpler payload for refresh token
      {
        expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
        secret: process.env.JWT_REFRESH_SECRET || 'fallback-refresh-secret',
      }
    );

    return { access_token, refresh_token };
  }

  private sanitizeUser(user: UserDocument): any {
    const userObj = user.toObject ? user.toObject() : user;
    const { password, ...userWithoutPassword } = userObj;
    return userWithoutPassword;
  }
}