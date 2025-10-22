import { Injectable, ExecutionContext, Logger } from '@nestjs/common';
import { ThrottlerGuard, ThrottlerException, ThrottlerRequest } from '@nestjs/throttler';
import { Request } from 'express';

@Injectable()
export class CustomThrottlerGuard extends ThrottlerGuard {
  private readonly logger = new Logger(CustomThrottlerGuard.name);

  protected async getTracker(req: Request): Promise<string> {
    // Use IP address as tracker for rate limiting
    return req.ip || 'unknown';
  }

  protected async handleRequest(requestProps: ThrottlerRequest): Promise<boolean> {
    const context = requestProps.context;
    const limit = requestProps.limit;
    const ttl = requestProps.ttl;
    const httpContext = context.switchToHttp();
    const request = httpContext.getRequest<Request>();
    const response = httpContext.getResponse();
    
    // Different limits for different endpoints
    const path = request.route?.path || request.url;
    
    let customLimit = limit;
    let customTtl = ttl;
    
    // Stricter limits for auth endpoints
    if (path.includes('/auth/')) {
      customLimit = 10; // 10 requests per minute for auth
      customTtl = 60000; // 1 minute
    }
    
    // More generous limits for regular API calls
    const clientKey = await this.getTracker(request);
    const key = this.generateKey(context, clientKey, 'default');
    const { totalHits, timeToExpire } = await this.storageService.increment(key, customTtl, customLimit, 0, 'default');

    // Set rate limit headers
    response.setHeader('X-RateLimit-Limit', customLimit);
    response.setHeader('X-RateLimit-Remaining', Math.max(0, customLimit - totalHits));
    response.setHeader('X-RateLimit-Reset', Math.ceil(timeToExpire / 1000));

    if (totalHits > customLimit) {
      // Log abusive behavior
      this.logger.warn(`Rate limit exceeded for IP: ${clientKey}, Path: ${path}`);
      throw new ThrottlerException();
    }

    return true;
  }
}