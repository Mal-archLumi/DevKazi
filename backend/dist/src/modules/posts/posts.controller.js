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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PostsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const jwt_auth_guard_1 = require("../../auth/guards/jwt-auth.guard");
const posts_service_1 = require("./posts.service");
const create_post_dto_1 = require("./dto/create-post.dto");
const update_post_dto_1 = require("./dto/update-post.dto");
const search_posts_dto_1 = require("./dto/search-posts.dto");
const post_response_dto_1 = require("./dto/post-response.dto");
const post_ownership_guard_1 = require("./guards/post-ownership.guard");
let PostsController = class PostsController {
    postsService;
    constructor(postsService) {
        this.postsService = postsService;
    }
    async create(createPostDto, req) {
        return this.postsService.create(createPostDto, req.user.userId);
    }
    async findAll(searchDto) {
        return this.postsService.findAll(searchDto);
    }
    async findOne(id) {
        return this.postsService.findOne(id);
    }
    async update(id, updatePostDto, req) {
        return this.postsService.update(id, updatePostDto, req.user.userId);
    }
    async remove(id, req) {
        return this.postsService.remove(id, req.user.userId);
    }
    async getTeamPosts(teamId, req) {
        return this.postsService.getTeamPosts(teamId, req.user.userId);
    }
};
exports.PostsController = PostsController;
__decorate([
    (0, common_1.Post)(),
    (0, swagger_1.ApiOperation)({ summary: 'Create a new internship post' }),
    (0, swagger_1.ApiResponse)({ status: 201, description: 'Post created successfully', type: post_response_dto_1.PostResponseDto }),
    (0, swagger_1.ApiResponse)({ status: 403, description: 'Forbidden - No team permission' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_post_dto_1.CreatePostDto, Object]),
    __metadata("design:returntype", Promise)
], PostsController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: 'Get all internship posts with filtering' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Posts retrieved successfully' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [search_posts_dto_1.SearchPostsDto]),
    __metadata("design:returntype", Promise)
], PostsController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Get a specific post by ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Post retrieved successfully', type: post_response_dto_1.PostResponseDto }),
    (0, swagger_1.ApiResponse)({ status: 404, description: 'Post not found' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], PostsController.prototype, "findOne", null);
__decorate([
    (0, common_1.Put)(':id'),
    (0, common_1.UseGuards)(post_ownership_guard_1.PostOwnershipGuard),
    (0, swagger_1.ApiOperation)({ summary: 'Update a post' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Post updated successfully', type: post_response_dto_1.PostResponseDto }),
    (0, swagger_1.ApiResponse)({ status: 404, description: 'Post not found' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_post_dto_1.UpdatePostDto, Object]),
    __metadata("design:returntype", Promise)
], PostsController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    (0, common_1.UseGuards)(post_ownership_guard_1.PostOwnershipGuard),
    (0, common_1.HttpCode)(common_1.HttpStatus.NO_CONTENT),
    (0, swagger_1.ApiOperation)({ summary: 'Delete a post' }),
    (0, swagger_1.ApiResponse)({ status: 204, description: 'Post deleted successfully' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: 'Post not found' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], PostsController.prototype, "remove", null);
__decorate([
    (0, common_1.Get)('team/:teamId'),
    (0, swagger_1.ApiOperation)({ summary: 'Get all posts for a specific team' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Team posts retrieved successfully' }),
    __param(0, (0, common_1.Param)('teamId')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], PostsController.prototype, "getTeamPosts", null);
exports.PostsController = PostsController = __decorate([
    (0, swagger_1.ApiTags)('posts'),
    (0, common_1.Controller)('posts'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    __metadata("design:paramtypes", [posts_service_1.PostsService])
], PostsController);
//# sourceMappingURL=posts.controller.js.map