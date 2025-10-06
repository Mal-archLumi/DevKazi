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
exports.PostsService = void 0;
const common_1 = require("@nestjs/common");
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
const post_schema_1 = require("./schemas/post.schema");
const teams_service_1 = require("../teams/teams.service");
let PostsService = class PostsService {
    postModel;
    teamsService;
    constructor(postModel, teamsService) {
        this.postModel = postModel;
        this.teamsService = teamsService;
    }
    async create(createPostDto, userId) {
        if (createPostDto.team) {
            await this.verifyTeamPermission(createPostDto.team, userId);
        }
        const postData = {
            ...createPostDto,
            createdBy: new mongoose_2.Types.ObjectId(userId),
        };
        if (createPostDto.team) {
            postData.team = new mongoose_2.Types.ObjectId(createPostDto.team);
        }
        const post = await this.postModel.create(postData);
        const populatedPost = await this.postModel
            .findById(post._id)
            .populate('team', 'name avatar description')
            .populate('createdBy', 'name avatar email')
            .exec();
        return this.mapToResponseDto(populatedPost);
    }
    async findAll(searchDto) {
        const { page = 1, limit = 10, search, category, skills, location, commitment, minStipend, maxStipend, sortBy, sortOrder } = searchDto;
        const query = {
            status: 'active',
            isPublic: true,
            applicationDeadline: { $gte: new Date() }
        };
        if (search) {
            query.$or = [
                { title: { $regex: search, $options: 'i' } },
                { description: { $regex: search, $options: 'i' } },
                { tags: { $in: [new RegExp(search, 'i')] } }
            ];
        }
        if (category)
            query.category = category;
        if (location)
            query.location = location;
        if (commitment)
            query.commitment = commitment;
        if (skills && skills.length > 0) {
            query.skillsRequired = { $in: skills };
        }
        if (minStipend !== undefined || maxStipend !== undefined) {
            query.stipend = {};
            if (minStipend !== undefined)
                query.stipend.$gte = minStipend;
            if (maxStipend !== undefined)
                query.stipend.$lte = maxStipend;
        }
        const sortOptions = {};
        sortOptions[sortBy || 'createdAt'] = sortOrder === 'desc' ? -1 : 1;
        const posts = await this.postModel
            .find(query)
            .populate('team', 'name avatar description')
            .populate('createdBy', 'name avatar email')
            .sort(sortOptions)
            .skip((page - 1) * limit)
            .limit(limit)
            .exec();
        const total = await this.postModel.countDocuments(query);
        return {
            posts: posts.map(post => this.mapToResponseDto(post)),
            total
        };
    }
    async findOne(id) {
        if (!mongoose_2.Types.ObjectId.isValid(id)) {
            throw new common_1.NotFoundException('Post not found');
        }
        const post = await this.postModel
            .findById(id)
            .populate('team', 'name avatar description members')
            .populate('createdBy', 'name avatar email')
            .exec();
        if (!post) {
            throw new common_1.NotFoundException('Post not found');
        }
        return this.mapToResponseDto(post);
    }
    async update(id, updatePostDto, userId) {
        await this.checkPostOwnership(id, userId);
        const post = await this.postModel
            .findByIdAndUpdate(id, updatePostDto, { new: true, runValidators: true })
            .populate('team', 'name avatar description')
            .populate('createdBy', 'name avatar email')
            .exec();
        if (!post) {
            throw new common_1.NotFoundException('Post not found');
        }
        return this.mapToResponseDto(post);
    }
    async remove(id, userId) {
        await this.checkPostOwnership(id, userId);
        const result = await this.postModel.findByIdAndDelete(id).exec();
        if (!result) {
            throw new common_1.NotFoundException('Post not found');
        }
    }
    async getTeamPosts(teamId, userId) {
        await this.teamsService.verifyTeamMembership(teamId, userId);
        const posts = await this.postModel
            .find({ team: new mongoose_2.Types.ObjectId(teamId) })
            .populate('team', 'name avatar description')
            .populate('createdBy', 'name avatar email')
            .sort({ createdAt: -1 })
            .exec();
        return posts.map(post => this.mapToResponseDto(post));
    }
    async checkPostOwnership(postId, userId) {
        const post = await this.postModel.findById(postId).exec();
        if (!post) {
            throw new common_1.NotFoundException('Post not found');
        }
        if (post.team) {
            return this.verifyTeamPermission(post.team.toString(), userId);
        }
        return post.createdBy.toString() === userId;
    }
    async incrementApplicationsCount(postId) {
        await this.postModel.findByIdAndUpdate(postId, {
            $inc: { applicationsCount: 1 }
        }).exec();
    }
    async verifyTeamPermission(teamId, userId) {
        const team = await this.teamsService.getTeamById(teamId);
        const isAdmin = team.members.some(member => member.user.toString() === userId && ['owner', 'admin'].includes(member.role));
        if (!isAdmin) {
            throw new common_1.ForbiddenException('You do not have permission to manage posts for this team');
        }
        return true;
    }
    mapToResponseDto(post) {
        if (!post)
            throw new Error('Post data is required');
        const teamDto = post.team && typeof post.team === 'object' ? {
            _id: post.team._id,
            name: post.team.name,
            avatar: post.team.avatar,
            description: post.team.description,
        } : undefined;
        const createdByDto = post.createdBy && typeof post.createdBy === 'object' ? {
            _id: post.createdBy._id,
            name: post.createdBy.name,
            avatar: post.createdBy.avatar,
            email: post.createdBy.email,
        } : {
            _id: new mongoose_2.Types.ObjectId(),
            name: 'Unknown User',
            email: undefined,
            avatar: undefined,
        };
        return {
            _id: post._id,
            title: post.title,
            description: post.description,
            requirements: post.requirements,
            skillsRequired: post.skillsRequired,
            category: post.category,
            team: teamDto,
            createdBy: createdByDto,
            applicationDeadline: post.applicationDeadline,
            duration: post.duration,
            commitment: post.commitment,
            location: post.location,
            stipend: post.stipend,
            positions: post.positions,
            applicationsCount: post.applicationsCount,
            status: post.status,
            tags: post.tags,
            isPublic: post.isPublic,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
        };
    }
};
exports.PostsService = PostsService;
exports.PostsService = PostsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, mongoose_1.InjectModel)(post_schema_1.Post.name)),
    __param(1, (0, common_1.Inject)((0, common_1.forwardRef)(() => teams_service_1.TeamsService))),
    __metadata("design:paramtypes", [mongoose_2.Model,
        teams_service_1.TeamsService])
], PostsService);
//# sourceMappingURL=posts.service.js.map