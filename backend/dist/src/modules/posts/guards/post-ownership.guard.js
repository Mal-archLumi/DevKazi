"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PostOwnershipGuard = void 0;
const common_1 = require("@nestjs/common");
const posts_service_1 = require("../posts.service");
let PostOwnershipGuard = class PostOwnershipGuard {
    postsService;
    constructor(postsService) {
        this.postsService = postsService;
    }
    async canActivate(context) {
        const request = context.switchToHttp().getRequest();
        const user = request.user;
        const postId = request.params.id;
        const hasPermission = await this.postsService.checkPostOwnership(postId, user.userId);
        if (!hasPermission) {
            throw new common_1.ForbiddenException('You do not have permission to perform this action');
        }
        return true;
    }
};
exports.PostOwnershipGuard = PostOwnershipGuard;
exports.PostOwnershipGuard = PostOwnershipGuard = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [posts_service_1.PostsService])
], PostOwnershipGuard);
//# sourceMappingURL=post-ownership.guard.js.map