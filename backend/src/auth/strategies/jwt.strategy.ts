// auth/strategies/jwt.strategy.ts - UPDATED WITH BETTER ERROR HANDLING
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable, UnauthorizedException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { User, UserRole } from '../../modules/users/schemas/user.schema';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  private readonly logger = new Logger(JwtStrategy.name);

  constructor(
    private configService: ConfigService,
    @InjectModel(User.name) private userModel: Model<User>,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromExtractors([
        (request: any) => {
          // 1. WebSocket: handshake.auth.token
          if (request?.handshake?.auth?.token) {
            return request.handshake.auth.token;
          }
          // 2. HTTP: Bearer token
          if (request?.headers?.authorization?.startsWith('Bearer ')) {
            return request.headers.authorization.split(' ')[1];
          }
          // 3. Cookie fallback (optional)
          return request?.cookies?.access_token || null;
        },
      ]),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_SECRET') || 'fallback-secret',
    });
  }

  async validate(payload: any) {
    try {
      this.logger.debug(`Validating JWT payload: ${JSON.stringify(payload, null, 2)}`);
      
      // Handle missing sub/payload
      if (!payload || !payload.sub) {
        this.logger.warn('JWT validation failed: No sub in payload');
        throw new UnauthorizedException('Invalid token payload');
      }

      const user = await this.userModel
        .findById(payload.sub)
        .select('-password -resetPasswordToken -resetPasswordExpires');
      
      if (!user) {
        this.logger.warn(`JWT validation failed: User not found for sub ${payload.sub}`);
        throw new UnauthorizedException('User not found');
      }

      if (!user.isActive) {
        this.logger.warn(`JWT validation failed: User ${payload.sub} is inactive`);
        throw new UnauthorizedException('Account is deactivated');
      }

      // Get role from user document (not from token for security)
      const userRole = user.role || UserRole.USER;
      
      return {
        userId: (user._id as Types.ObjectId).toString(),
        email: user.email,
        name: user.name,
        isVerified: user.isVerified,
        role: userRole,
        permissions: user.permissions || [],
        isAdmin: userRole === UserRole.ADMIN || userRole === UserRole.SUPER_ADMIN,
      };
    } catch (error) {
      this.logger.error(`JWT validation error: ${error.message}`);
      
      // Re-throw UnauthorizedException as is
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      
      throw new UnauthorizedException('Invalid token');
    }
  }
}