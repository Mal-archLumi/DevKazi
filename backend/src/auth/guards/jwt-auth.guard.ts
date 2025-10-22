import {
  Injectable,
  ExecutionContext,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Reflector } from '@nestjs/core';
import { Observable } from 'rxjs';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  private readonly logger = new Logger(JwtAuthGuard.name);

  constructor(private reflector: Reflector) {
    super();
  }

  canActivate(context: ExecutionContext): boolean | Promise<boolean> | Observable<boolean> {
    // Check if the route is public
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) {
      return true;
    }

    return super.canActivate(context);
  }

  handleRequest(err: any, user: any, info: any, context: ExecutionContext) {
    // Log authentication errors for security monitoring
    if (err || !user) {
      const request = context.switchToHttp().getRequest();
      this.logger.warn(`JWT Authentication failed for ${request.method} ${request.url}: ${info?.message || err?.message}`);
      
      if (info?.name === 'TokenExpiredError') {
        throw new UnauthorizedException('Token has expired');
      } else if (info?.name === 'JsonWebTokenError') {
        throw new UnauthorizedException('Invalid token');
      } else if (info?.name === 'NotBeforeError') {
        throw new UnauthorizedException('Token not active');
      }
      
      throw new UnauthorizedException('Authentication required');
    }

    // Add user context to request for logging
    const request = context.switchToHttp().getRequest();
    request.userContext = {
      userId: user.userId,
      email: user.email,
      ip: request.ip,
      userAgent: request.get('user-agent'),
      timestamp: new Date().toISOString(),
    };

    return user;
  }
}