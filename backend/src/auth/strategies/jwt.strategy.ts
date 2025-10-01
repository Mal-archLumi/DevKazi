import { ExtractJwt, Strategy } from 'passport-jwt';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable, UnauthorizedException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { User } from '../../modules/users/schemas/user.schema';

// Create a proper interface for the user document
interface IUserDocument {
  _id: Types.ObjectId;
  email: string;
  name: string;
  roles: string[];
  isVerified: boolean;
  toObject(): any;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  private readonly logger = new Logger(JwtStrategy.name);

  constructor(
    private configService: ConfigService,
    @InjectModel(User.name) private userModel: Model<User>,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_SECRET') || 'fallback-secret',
    });
  }

  async validate(payload: any) {
    try {
      const user = await this.userModel.findById(payload.sub).select('-password') as unknown as IUserDocument;
      
      if (!user) {
        this.logger.warn(`JWT validation failed: User not found for sub ${payload.sub}`);
        throw new UnauthorizedException('User not found');
      }

      return {
        userId: user._id.toString(),
        email: user.email,
        name: user.name,
        roles: user.roles,
        isVerified: user.isVerified,
      };
    } catch (error) {
      this.logger.error(`JWT validation error: ${error.message}`);
      throw new UnauthorizedException('Invalid token');
    }
  }
}