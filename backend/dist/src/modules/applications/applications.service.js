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
exports.ApplicationsService = void 0;
const common_1 = require("@nestjs/common");
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
const application_schema_1 = require("./schemas/application.schema");
const posts_service_1 = require("../posts/posts.service");
const teams_service_1 = require("../teams/teams.service");
let ApplicationsService = class ApplicationsService {
    applicationModel;
    postsService;
    teamsService;
    constructor(applicationModel, postsService, teamsService) {
        this.applicationModel = applicationModel;
        this.postsService = postsService;
        this.teamsService = teamsService;
    }
    async create(createApplicationDto, userId) {
        const post = await this.postsService.findOne(createApplicationDto.post);
        this.validatePostForApplication(post);
        const existingApplication = await this.applicationModel.findOne({
            post: new mongoose_2.Types.ObjectId(createApplicationDto.post),
            applicant: new mongoose_2.Types.ObjectId(userId),
        });
        if (existingApplication) {
            throw new common_1.BadRequestException('You have already applied to this post');
        }
        const applicationData = {
            ...createApplicationDto,
            post: new mongoose_2.Types.ObjectId(createApplicationDto.post),
            applicant: new mongoose_2.Types.ObjectId(userId),
        };
        if (post.team && post.team._id) {
            applicationData.team = post.team._id;
        }
        const application = new this.applicationModel(applicationData);
        await application.save();
        await this.postsService.incrementApplicationsCount(createApplicationDto.post);
        const populatedApplication = await this.applicationModel
            .findById(application._id)
            .populate('post', 'title team')
            .populate('applicant', 'name avatar email')
            .populate('team', 'name avatar')
            .exec();
        return this.mapToResponseDto(populatedApplication);
    }
    async getUserApplications(userId) {
        const applications = await this.applicationModel
            .find({ applicant: new mongoose_2.Types.ObjectId(userId) })
            .populate('post', 'title team applicationDeadline')
            .populate('team', 'name avatar')
            .populate('reviewedBy', 'name avatar')
            .sort({ appliedAt: -1 })
            .exec();
        return applications.map(app => this.mapToResponseDto(app));
    }
    async getTeamApplications(teamId, userId) {
        await this.teamsService.verifyTeamAdmin(teamId, userId);
        const applications = await this.applicationModel
            .find({ team: new mongoose_2.Types.ObjectId(teamId) })
            .populate('post', 'title')
            .populate('applicant', 'name avatar email skills')
            .populate('reviewedBy', 'name avatar')
            .sort({ appliedAt: -1 })
            .exec();
        return applications.map(app => this.mapToResponseDto(app));
    }
    async updateStatus(applicationId, statusDto, userId) {
        const application = await this.applicationModel.findById(applicationId);
        if (!application) {
            throw new common_1.NotFoundException('Application not found');
        }
        if (application.team) {
            await this.teamsService.verifyTeamAdmin(application.team.toString(), userId);
        }
        else {
            const post = await this.postsService.findOne(application.post.toString());
            if (post.createdBy._id.toString() !== userId) {
                throw new common_1.ForbiddenException('Only the post creator can manage applications for this post');
            }
        }
        this.validateStatusTransition(application.status, statusDto.status);
        const updatedApplication = await this.applicationModel
            .findByIdAndUpdate(applicationId, {
            status: statusDto.status,
            reviewedAt: new Date(),
            reviewedBy: new mongoose_2.Types.ObjectId(userId),
            notes: statusDto.notes,
        }, { new: true, runValidators: true })
            .populate('post', 'title team')
            .populate('applicant', 'name avatar email')
            .populate('team', 'name avatar')
            .populate('reviewedBy', 'name avatar')
            .exec();
        return this.mapToResponseDto(updatedApplication);
    }
    async getApplicationStats(teamId, userId) {
        await this.teamsService.verifyTeamAdmin(teamId, userId);
        const stats = await this.applicationModel.aggregate([
            { $match: { team: new mongoose_2.Types.ObjectId(teamId) } },
            {
                $group: {
                    _id: '$status',
                    count: { $sum: 1 }
                }
            }
        ]);
        return stats.reduce((acc, curr) => {
            acc[curr._id] = curr.count;
            return acc;
        }, { pending: 0, accepted: 0, rejected: 0, withdrawn: 0 });
    }
    async getApplicationAnalytics(teamId, userId) {
        await this.teamsService.verifyTeamAdmin(teamId, userId);
        const analytics = await this.applicationModel.aggregate([
            { $match: { team: new mongoose_2.Types.ObjectId(teamId) } },
            {
                $lookup: {
                    from: 'posts',
                    localField: 'post',
                    foreignField: '_id',
                    as: 'postDetails'
                }
            },
            { $unwind: '$postDetails' },
            {
                $group: {
                    _id: '$post',
                    postTitle: { $first: '$postDetails.title' },
                    statusBreakdown: {
                        $push: {
                            status: '$status',
                            count: 1
                        }
                    },
                    totalApplications: { $sum: 1 }
                }
            },
            {
                $project: {
                    postTitle: 1,
                    totalApplications: 1,
                    statusBreakdown: {
                        $arrayToObject: {
                            $map: {
                                input: '$statusBreakdown',
                                as: 'item',
                                in: {
                                    k: '$$item.status',
                                    v: '$$item.count'
                                }
                            }
                        }
                    }
                }
            }
        ]);
        return analytics;
    }
    async withdrawApplication(applicationId, userId) {
        const application = await this.applicationModel.findById(applicationId);
        if (!application) {
            throw new common_1.NotFoundException('Application not found');
        }
        if (application.applicant.toString() !== userId) {
            throw new common_1.ForbiddenException('You can only withdraw your own applications');
        }
        if (application.status !== 'pending') {
            throw new common_1.BadRequestException('Cannot withdraw a processed application');
        }
        const updatedApplication = await this.applicationModel
            .findByIdAndUpdate(applicationId, {
            status: 'withdrawn',
            reviewedAt: new Date(),
        }, { new: true })
            .populate('post', 'title team')
            .populate('applicant', 'name avatar email')
            .populate('team', 'name avatar')
            .exec();
        return this.mapToResponseDto(updatedApplication);
    }
    validatePostForApplication(post) {
        if (post.status !== 'active') {
            throw new common_1.BadRequestException('Cannot apply to an inactive post');
        }
        if (new Date(post.applicationDeadline) < new Date()) {
            throw new common_1.BadRequestException('Application deadline has passed');
        }
    }
    validateStatusTransition(currentStatus, newStatus) {
        const validTransitions = {
            'pending': ['accepted', 'rejected', 'withdrawn'],
            'accepted': ['withdrawn'],
            'rejected': ['withdrawn'],
            'withdrawn': []
        };
        if (!validTransitions[currentStatus]?.includes(newStatus)) {
            throw new common_1.BadRequestException(`Invalid status transition from ${currentStatus} to ${newStatus}`);
        }
    }
    mapToResponseDto(application) {
        if (!application) {
            throw new common_1.NotFoundException('Application not found');
        }
        const postDto = application.post && typeof application.post === 'object' ? {
            _id: application.post._id,
            title: application.post.title,
            team: application.post.team,
        } : {
            _id: application.post || new mongoose_2.Types.ObjectId(),
            title: 'Unknown Post',
            team: undefined,
        };
        const applicantDto = application.applicant && typeof application.applicant === 'object' ? {
            _id: application.applicant._id,
            name: application.applicant.name,
            avatar: application.applicant.avatar,
            email: application.applicant.email,
        } : {
            _id: new mongoose_2.Types.ObjectId(),
            name: 'Unknown User',
            avatar: undefined,
            email: undefined,
        };
        const teamDto = application.team && typeof application.team === 'object' ? {
            _id: application.team._id,
            name: application.team.name,
            avatar: application.team.avatar,
        } : undefined;
        const reviewedByDto = application.reviewedBy && typeof application.reviewedBy === 'object' ? {
            _id: application.reviewedBy._id,
            name: application.reviewedBy.name,
            avatar: application.reviewedBy.avatar,
            email: application.reviewedBy.email,
        } : undefined;
        return {
            _id: application._id,
            post: postDto,
            applicant: applicantDto,
            team: teamDto,
            coverLetter: application.coverLetter,
            resume: application.resume,
            skills: application.skills,
            experience: application.experience,
            status: application.status,
            appliedAt: application.appliedAt,
            reviewedAt: application.reviewedAt,
            reviewedBy: reviewedByDto,
            notes: application.notes,
            createdAt: application.createdAt,
            updatedAt: application.updatedAt,
        };
    }
};
exports.ApplicationsService = ApplicationsService;
exports.ApplicationsService = ApplicationsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, mongoose_1.InjectModel)(application_schema_1.Application.name)),
    __param(1, (0, common_1.Inject)((0, common_1.forwardRef)(() => posts_service_1.PostsService))),
    __param(2, (0, common_1.Inject)((0, common_1.forwardRef)(() => teams_service_1.TeamsService))),
    __metadata("design:paramtypes", [mongoose_2.Model,
        posts_service_1.PostsService,
        teams_service_1.TeamsService])
], ApplicationsService);
//# sourceMappingURL=applications.service.js.map