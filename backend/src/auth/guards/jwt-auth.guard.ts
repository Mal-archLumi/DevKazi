import {
  Injectable,
  ExecutionContext,
  UnauthorizedException,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Reflector } from '@nestjs/core';
import { Observable } from 'rxjs';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';
import { ROLES_KEY } from '../decorators/roles.decorator';
import { Role } from '../enums/role.enum';

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

    // Check role-based access control if roles are defined
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (requiredRoles && requiredRoles.length > 0) {
      const hasRole = requiredRoles.some(role => user.roles?.includes(role));
      if (!hasRole) {
        this.logger.warn(`User ${user.userId} attempted to access protected route without required roles: ${requiredRoles.join(', ')}`);
        throw new ForbiddenException('Insufficient permissions');
      }
    }

    // Add additional user context to request for logging and auditing
    const request = context.switchToHttp().getRequest();
    request.userContext = {
      userId: user.userId,
      email: user.email,
      roles: user.roles,
      ip: request.ip,
      userAgent: request.get('user-agent'),
      timestamp: new Date().toISOString(),
    };

    return user;
  }
}