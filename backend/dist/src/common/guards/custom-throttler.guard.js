"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var CustomThrottlerGuard_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.CustomThrottlerGuard = void 0;
const common_1 = require("@nestjs/common");
const throttler_1 = require("@nestjs/throttler");
let CustomThrottlerGuard = CustomThrottlerGuard_1 = class CustomThrottlerGuard extends throttler_1.ThrottlerGuard {
    logger = new common_1.Logger(CustomThrottlerGuard_1.name);
    async getTracker(req) {
        return req.ip || 'unknown';
    }
    async handleRequest(requestProps) {
        const context = requestProps.context;
        const limit = requestProps.limit;
        const ttl = requestProps.ttl;
        const httpContext = context.switchToHttp();
        const request = httpContext.getRequest();
        const response = httpContext.getResponse();
        const path = request.route?.path || request.url;
        let customLimit = limit;
        let customTtl = ttl;
        if (path.includes('/auth/')) {
            customLimit = 10;
            customTtl = 60000;
        }
        const clientKey = await this.getTracker(request);
        const key = this.generateKey(context, clientKey, 'default');
        const { totalHits, timeToExpire } = await this.storageService.increment(key, customTtl, customLimit, 0, 'default');
        response.setHeader('X-RateLimit-Limit', customLimit);
        response.setHeader('X-RateLimit-Remaining', Math.max(0, customLimit - totalHits));
        response.setHeader('X-RateLimit-Reset', Math.ceil(timeToExpire / 1000));
        if (totalHits > customLimit) {
            this.logger.warn(`Rate limit exceeded for IP: ${clientKey}, Path: ${path}`);
            throw new throttler_1.ThrottlerException();
        }
        return true;
    }
};
exports.CustomThrottlerGuard = CustomThrottlerGuard;
exports.CustomThrottlerGuard = CustomThrottlerGuard = CustomThrottlerGuard_1 = __decorate([
    (0, common_1.Injectable)()
], CustomThrottlerGuard);
//# sourceMappingURL=custom-throttler.guard.js.map