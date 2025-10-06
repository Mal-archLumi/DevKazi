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
exports.TeamsController = void 0;
const common_1 = require("@nestjs/common");
const teams_service_1 = require("./teams.service");
const jwt_auth_guard_1 = require("../../common/guards/jwt-auth.guard");
const create_team_dto_1 = require("./dto/create-team.dto");
const update_team_dto_1 = require("./dto/update-team.dto");
const invite_member_dto_1 = require("./dto/invite-member.dto");
const swagger_1 = require("@nestjs/swagger");
let TeamsController = class TeamsController {
    teamsService;
    constructor(teamsService) {
        this.teamsService = teamsService;
    }
    async create(createTeamDto, req) {
        return this.teamsService.create(createTeamDto, req.user.userId);
    }
    async findAll(page, limit, search) {
        return this.teamsService.findAll(page, limit, search);
    }
    async searchTeams(skills, search, page, limit) {
        const skillsArray = skills ? skills.split(',') : undefined;
        return this.teamsService.searchTeams(skillsArray, search, page, limit);
    }
    async getUserTeams(req) {
        return this.teamsService.getUserTeams(req.user.userId);
    }
    async findOne(id) {
        return this.teamsService.findOne(id);
    }
    async update(id, updateTeamDto, req) {
        return this.teamsService.update(id, updateTeamDto, req.user.userId);
    }
    async remove(id, req) {
        return this.teamsService.remove(id, req.user.userId);
    }
    async inviteMember(id, inviteMemberDto, req) {
        return this.teamsService.inviteMember(id, inviteMemberDto, req.user.userId);
    }
    async joinTeam(id, req, body) {
        return this.teamsService.joinTeam(id, req.user.userId, body.message);
    }
    async respondToJoinRequest(id, userId, req, body) {
        return this.teamsService.respondToJoinRequest(id, userId, req.user.userId, body.accept);
    }
    async removeMember(id, memberId, req) {
        return this.teamsService.removeMember(id, memberId, req.user.userId);
    }
};
exports.TeamsController = TeamsController;
__decorate([
    (0, common_1.Post)(),
    (0, swagger_1.ApiOperation)({ summary: 'Create a new team' }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.CREATED,
        description: 'Team created successfully'
    }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.BAD_REQUEST,
        description: 'Invalid input'
    }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.UNAUTHORIZED,
        description: 'Unauthorized'
    }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_team_dto_1.CreateTeamDto, Object]),
    __metadata("design:returntype", Promise)
], TeamsController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: 'Get all teams with pagination and search' }),
    (0, swagger_1.ApiQuery)({ name: 'page', required: false, type: Number, example: 1 }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, type: Number, example: 10 }),
    (0, swagger_1.ApiQuery)({ name: 'search', required: false, type: String }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.OK,
        description: 'Teams retrieved successfully'
    }),
    __param(0, (0, common_1.Query)('page', new common_1.DefaultValuePipe(1), common_1.ParseIntPipe)),
    __param(1, (0, common_1.Query)('limit', new common_1.DefaultValuePipe(10), common_1.ParseIntPipe)),
    __param(2, (0, common_1.Query)('search')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Number, String]),
    __metadata("design:returntype", Promise)
], TeamsController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)('search'),
    (0, swagger_1.ApiOperation)({ summary: 'Search teams by skills and keywords' }),
    (0, swagger_1.ApiQuery)({ name: 'skills', required: false, type: String }),
    (0, swagger_1.ApiQuery)({ name: 'search', required: false, type: String }),
    (0, swagger_1.ApiQuery)({ name: 'page', required: false, type: Number, example: 1 }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, type: Number, example: 10 }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.OK,
        description: 'Teams search completed successfully'
    }),
    __param(0, (0, common_1.Query)('skills')),
    __param(1, (0, common_1.Query)('search')),
    __param(2, (0, common_1.Query)('page', new common_1.DefaultValuePipe(1), common_1.ParseIntPipe)),
    __param(3, (0, common_1.Query)('limit', new common_1.DefaultValuePipe(10), common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, Number, Number]),
    __metadata("design:returntype", Promise)
], TeamsController.prototype, "searchTeams", null);
__decorate([
    (0, common_1.Get)('my-teams'),
    (0, swagger_1.ApiOperation)({ summary: 'Get current user teams' }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.OK,
        description: 'User teams retrieved successfully'
    }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], TeamsController.prototype, "getUserTeams", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Get team by ID' }),
    (0, swagger_1.ApiParam)({ name: 'id', type: String, description: 'Team ID' }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.OK,
        description: 'Team retrieved successfully'
    }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.NOT_FOUND,
        description: 'Team not found'
    }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], TeamsController.prototype, "findOne", null);
__decorate([
    (0, common_1.Put)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Update team' }),
    (0, swagger_1.ApiParam)({ name: 'id', type: String, description: 'Team ID' }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.OK,
        description: 'Team updated successfully'
    }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.FORBIDDEN,
        description: 'Forbidden'
    }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.NOT_FOUND,
        description: 'Team not found'
    }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_team_dto_1.UpdateTeamDto, Object]),
    __metadata("design:returntype", Promise)
], TeamsController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Delete team' }),
    (0, swagger_1.ApiParam)({ name: 'id', type: String, description: 'Team ID' }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.OK,
        description: 'Team deleted successfully'
    }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.FORBIDDEN,
        description: 'Forbidden'
    }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.NOT_FOUND,
        description: 'Team not found'
    }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], TeamsController.prototype, "remove", null);
__decorate([
    (0, common_1.Post)(':id/invite'),
    (0, swagger_1.ApiOperation)({ summary: 'Invite member to team' }),
    (0, swagger_1.ApiParam)({ name: 'id', type: String, description: 'Team ID' }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.OK,
        description: 'Member invited successfully'
    }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.FORBIDDEN,
        description: 'Forbidden'
    }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.NOT_FOUND,
        description: 'Team or user not found'
    }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, invite_member_dto_1.InviteMemberDto, Object]),
    __metadata("design:returntype", Promise)
], TeamsController.prototype, "inviteMember", null);
__decorate([
    (0, common_1.Post)(':id/join'),
    (0, swagger_1.ApiOperation)({ summary: 'Request to join a team' }),
    (0, swagger_1.ApiParam)({ name: 'id', type: String, description: 'Team ID' }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.OK,
        description: 'Join request sent successfully'
    }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.FORBIDDEN,
        description: 'Forbidden'
    }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.NOT_FOUND,
        description: 'Team not found'
    }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object, Object]),
    __metadata("design:returntype", Promise)
], TeamsController.prototype, "joinTeam", null);
__decorate([
    (0, common_1.Post)(':id/join-requests/:userId/respond'),
    (0, swagger_1.ApiOperation)({ summary: 'Respond to join request' }),
    (0, swagger_1.ApiParam)({ name: 'id', type: String, description: 'Team ID' }),
    (0, swagger_1.ApiParam)({ name: 'userId', type: String, description: 'User ID who requested to join' }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.OK,
        description: 'Join request responded successfully'
    }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.FORBIDDEN,
        description: 'Forbidden'
    }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.NOT_FOUND,
        description: 'Team or request not found'
    }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Param)('userId')),
    __param(2, (0, common_1.Request)()),
    __param(3, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, Object, Object]),
    __metadata("design:returntype", Promise)
], TeamsController.prototype, "respondToJoinRequest", null);
__decorate([
    (0, common_1.Delete)(':id/members/:memberId'),
    (0, swagger_1.ApiOperation)({ summary: 'Remove member from team' }),
    (0, swagger_1.ApiParam)({ name: 'id', type: String, description: 'Team ID' }),
    (0, swagger_1.ApiParam)({ name: 'memberId', type: String, description: 'Member ID to remove' }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.OK,
        description: 'Member removed successfully'
    }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.FORBIDDEN,
        description: 'Forbidden'
    }),
    (0, swagger_1.ApiResponse)({
        status: common_1.HttpStatus.NOT_FOUND,
        description: 'Team or member not found'
    }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Param)('memberId')),
    __param(2, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, Object]),
    __metadata("design:returntype", Promise)
], TeamsController.prototype, "removeMember", null);
exports.TeamsController = TeamsController = __decorate([
    (0, swagger_1.ApiTags)('teams'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Controller)('teams'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __metadata("design:paramtypes", [teams_service_1.TeamsService])
], TeamsController);
//# sourceMappingURL=teams.controller.js.map