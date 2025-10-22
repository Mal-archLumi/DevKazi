import { ThrottlerGuard, ThrottlerRequest } from '@nestjs/throttler';
import { Request } from 'express';
export declare class CustomThrottlerGuard extends ThrottlerGuard {
    private readonly logger;
    protected getTracker(req: Request): Promise<string>;
    protected handleRequest(requestProps: ThrottlerRequest): Promise<boolean>;
}
