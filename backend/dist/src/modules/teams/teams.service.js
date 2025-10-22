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
var TeamsService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.TeamsService = void 0;
const common_1 = require("@nestjs/common");
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
const team_schema_1 = require("./schemas/team.schema");
const user_schema_1 = require("../users/schemas/user.schema");
let TeamsService = TeamsService_1 = class TeamsService {
    teamModel;
    userModel;
    logger = new common_1.Logger(TeamsService_1.name);
    constructor(teamModel, userModel) {
        this.teamModel = teamModel;
        this.userModel = userModel;
    }
    generateInviteCode() {
        return Math.random().toString(36).substring(2, 8).toUpperCase();
    }
    getUserId(userRef) {
        try {
            if (userRef instanceof mongoose_2.Types.ObjectId) {
                return userRef.toString();
            }
            if (userRef && userRef._id) {
                return userRef._id.toString();
            }
            if (typeof userRef === 'string') {
                return userRef;
            }
            return String(userRef);
        }
        catch (error) {
            this.logger.warn(`Failed to extract user ID from: ${userRef}`);
            throw new common_1.BadRequestException('Invalid user reference');
        }
    }
    isUserOwner(team, userId) {
        const ownerId = this.getUserId(team.owner);
        return ownerId === userId;
    }
    isUserMember(team, userId) {
        return team.members.some(member => this.getUserId(member.user) === userId);
    }
    async create(createTeamDto, userId) {
        try {
            const user = await this.userModel.findById(userId);
            if (!user) {
                throw new common_1.NotFoundException('User not found');
            }
            let inviteCode;
            let isUnique = false;
            let attempts = 0;
            while (!isUnique && attempts < 10) {
                inviteCode = this.generateInviteCode();
                const existingTeam = await this.teamModel.findOne({ inviteCode });
                if (!existingTeam) {
                    isUnique = true;
                }
                attempts++;
            }
            if (!isUnique) {
                throw new common_1.InternalServerErrorException('Failed to generate unique invite code');
            }
            const teamData = {
                ...createTeamDto,
                owner: new mongoose_2.Types.ObjectId(userId),
                members: [{
                        user: new mongoose_2.Types.ObjectId(userId),
                        joinedAt: new Date(),
                    }],
                inviteCode: inviteCode,
                lastActivity: new Date(),
            };
            const team = new this.teamModel(teamData);
            const savedTeam = await team.save();
            this.logger.log(`Team created: ${savedTeam._id} by user: ${userId}`);
            return savedTeam;
        }
        catch (error) {
            this.logger.error(`Create team error: ${error.message}`);
            if (error instanceof common_1.NotFoundException)
                throw error;
            throw new common_1.InternalServerErrorException('Failed to create team');
        }
    }
    async findOne(id) {
        try {
            if (!mongoose_2.Types.ObjectId.isValid(id)) {
                throw new common_1.BadRequestException('Invalid team ID');
            }
            const team = await this.teamModel
                .findById(id)
                .populate('owner', 'name email')
                .populate('members.user', 'name email')
                .exec();
            if (!team) {
                throw new common_1.NotFoundException('Team not found');
            }
            return team;
        }
        catch (error) {
            this.logger.error(`Failed to fetch team ${id}: ${error.message}`);
            if (error instanceof common_1.NotFoundException || error instanceof common_1.BadRequestException) {
                throw error;
            }
            throw new common_1.InternalServerErrorException('Failed to fetch team');
        }
    }
    async update(id, updateTeamDto, userId) {
        try {
            if (!mongoose_2.Types.ObjectId.isValid(id)) {
                throw new common_1.BadRequestException('Invalid team ID');
            }
            const team = await this.teamModel.findById(id);
            if (!team) {
                throw new common_1.NotFoundException('Team not found');
            }
            if (!this.isUserOwner(team, userId)) {
                throw new common_1.ForbiddenException('Only team owner can update the team');
            }
            const updatedTeam = await this.teamModel
                .findByIdAndUpdate(id, {
                ...updateTeamDto,
                lastActivity: new Date()
            }, {
                new: true,
                runValidators: true
            })
                .populate('owner', 'name email')
                .populate('members.user', 'name email')
                .exec();
            if (!updatedTeam) {
                throw new common_1.NotFoundException('Team not found after update');
            }
            this.logger.log(`Team updated: ${id} by user: ${userId}`);
            return updatedTeam;
        }
        catch (error) {
            this.logger.error(`Failed to update team ${id}: ${error.message}`);
            if (error instanceof common_1.NotFoundException || error instanceof common_1.ForbiddenException || error instanceof common_1.BadRequestException) {
                throw error;
            }
            throw new common_1.InternalServerErrorException('Failed to update team');
        }
    }
    async remove(id, userId) {
        try {
            if (!mongoose_2.Types.ObjectId.isValid(id)) {
                throw new common_1.BadRequestException('Invalid team ID');
            }
            const team = await this.teamModel.findById(id);
            if (!team) {
                throw new common_1.NotFoundException('Team not found');
            }
            if (!this.isUserOwner(team, userId)) {
                throw new common_1.ForbiddenException('Only team owner can delete the team');
            }
            const result = await this.teamModel.findByIdAndDelete(id).exec();
            if (!result) {
                throw new common_1.NotFoundException('Team not found during deletion');
            }
            this.logger.log(`Team deleted: ${id} by user: ${userId}`);
        }
        catch (error) {
            this.logger.error(`Failed to delete team ${id}: ${error.message}`);
            if (error instanceof common_1.NotFoundException || error instanceof common_1.ForbiddenException || error instanceof common_1.BadRequestException) {
                throw error;
            }
            throw new common_1.InternalServerErrorException('Failed to delete team');
        }
    }
    async inviteMember(teamId, inviteMemberDto, inviterId) {
        try {
            if (!mongoose_2.Types.ObjectId.isValid(teamId)) {
                throw new common_1.BadRequestException('Invalid team ID');
            }
            const team = await this.teamModel.findById(teamId);
            if (!team) {
                throw new common_1.NotFoundException('Team not found');
            }
            if (!this.isUserOwner(team, inviterId)) {
                throw new common_1.ForbiddenException('Only team owner can invite members');
            }
            const user = await this.userModel.findOne({
                email: inviteMemberDto.email.toLowerCase().trim()
            });
            if (!user) {
                throw new common_1.NotFoundException('User not found with this email');
            }
            const targetUserId = user._id.toString();
            const isAlreadyMember = team.members.some(member => this.getUserId(member.user) === targetUserId);
            if (isAlreadyMember) {
                throw new common_1.BadRequestException('User is already a team member');
            }
            team.lastActivity = new Date();
            const updatedTeam = await team.save();
            this.logger.log(`Member invited to team ${teamId}: ${targetUserId} by user: ${inviterId}`);
            return updatedTeam;
        }
        catch (error) {
            this.logger.error(`Failed to invite member to team ${teamId}: ${error.message}`);
            if (error instanceof common_1.NotFoundException || error instanceof common_1.ForbiddenException || error instanceof common_1.BadRequestException) {
                throw error;
            }
            throw new common_1.InternalServerErrorException('Failed to invite member');
        }
    }
    async joinTeam(inviteCode, userId) {
        try {
            const team = await this.teamModel.findOne({ inviteCode });
            if (!team) {
                throw new common_1.NotFoundException('Invalid invite code or team not found');
            }
            const isAlreadyMember = team.members.some(member => this.getUserId(member.user) === userId);
            if (isAlreadyMember) {
                throw new common_1.BadRequestException('You are already a member of this team');
            }
            team.members.push({
                user: new mongoose_2.Types.ObjectId(userId),
                joinedAt: new Date(),
            });
            team.lastActivity = new Date();
            const updatedTeam = await team.save();
            this.logger.log(`User ${userId} joined team ${team._id} using invite code`);
            return updatedTeam;
        }
        catch (error) {
            this.logger.error(`Failed to join team with code ${inviteCode}: ${error.message}`);
            if (error instanceof common_1.NotFoundException || error instanceof common_1.BadRequestException) {
                throw error;
            }
            throw new common_1.InternalServerErrorException('Failed to join team');
        }
    }
    async removeMember(teamId, memberId, removerId) {
        try {
            if (!mongoose_2.Types.ObjectId.isValid(teamId) || !mongoose_2.Types.ObjectId.isValid(memberId)) {
                throw new common_1.BadRequestException('Invalid team ID or member ID');
            }
            const team = await this.teamModel.findById(teamId);
            if (!team) {
                throw new common_1.NotFoundException('Team not found');
            }
            if (!this.isUserOwner(team, removerId)) {
                throw new common_1.ForbiddenException('Only team owner can remove members');
            }
            if (removerId === memberId) {
                throw new common_1.BadRequestException('Owner cannot remove themselves from the team');
            }
            const memberIndex = team.members.findIndex(member => this.getUserId(member.user) === memberId);
            if (memberIndex === -1) {
                throw new common_1.NotFoundException('Member not found in team');
            }
            team.members.splice(memberIndex, 1);
            team.lastActivity = new Date();
            const updatedTeam = await team.save();
            this.logger.log(`Member removed from team ${teamId}: ${memberId} by user: ${removerId}`);
            return updatedTeam;
        }
        catch (error) {
            this.logger.error(`Failed to remove member from team ${teamId}: ${error.message}`);
            if (error instanceof common_1.NotFoundException || error instanceof common_1.ForbiddenException || error instanceof common_1.BadRequestException) {
                throw error;
            }
            throw new common_1.InternalServerErrorException('Failed to remove member');
        }
    }
    async getUserTeams(userId) {
        try {
            if (!mongoose_2.Types.ObjectId.isValid(userId)) {
                throw new common_1.BadRequestException('Invalid user ID');
            }
            const teams = await this.teamModel
                .find({
                'members.user': new mongoose_2.Types.ObjectId(userId),
            })
                .populate('owner', 'name email')
                .populate('members.user', 'name email')
                .sort({ lastActivity: -1 })
                .exec();
            return teams;
        }
        catch (error) {
            this.logger.error(`Failed to fetch user teams for ${userId}: ${error.message}`);
            if (error instanceof common_1.BadRequestException) {
                throw error;
            }
            throw new common_1.InternalServerErrorException('Failed to fetch user teams');
        }
    }
    async regenerateInviteCode(teamId, userId) {
        try {
            if (!mongoose_2.Types.ObjectId.isValid(teamId)) {
                throw new common_1.BadRequestException('Invalid team ID');
            }
            const team = await this.teamModel.findById(teamId);
            if (!team) {
                throw new common_1.NotFoundException('Team not found');
            }
            if (!this.isUserOwner(team, userId)) {
                throw new common_1.ForbiddenException('Only team owner can regenerate invite code');
            }
            let newInviteCode;
            let isUnique = false;
            let attempts = 0;
            while (!isUnique && attempts < 10) {
                newInviteCode = this.generateInviteCode();
                const existingTeam = await this.teamModel.findOne({ inviteCode: newInviteCode });
                if (!existingTeam) {
                    isUnique = true;
                }
                attempts++;
            }
            if (!isUnique) {
                throw new common_1.InternalServerErrorException('Failed to generate unique invite code');
            }
            team.inviteCode = newInviteCode;
            team.lastActivity = new Date();
            const updatedTeam = await team.save();
            this.logger.log(`Invite code regenerated for team ${teamId} by user: ${userId}`);
            return updatedTeam;
        }
        catch (error) {
            this.logger.error(`Failed to regenerate invite code for team ${teamId}: ${error.message}`);
            if (error instanceof common_1.NotFoundException || error instanceof common_1.ForbiddenException || error instanceof common_1.BadRequestException) {
                throw error;
            }
            throw new common_1.InternalServerErrorException('Failed to regenerate invite code');
        }
    }
    async verifyTeamMembership(teamId, userId) {
        const team = await this.teamModel.findById(teamId);
        if (!team) {
            throw new common_1.NotFoundException('Team not found');
        }
        const isMember = this.isUserMember(team, userId);
        if (!isMember) {
            throw new common_1.ForbiddenException('You are not a member of this team');
        }
        return true;
    }
    async getTeamById(teamId) {
        const team = await this.teamModel.findById(teamId);
        if (!team) {
            throw new common_1.NotFoundException('Team not found');
        }
        return team;
    }
};
exports.TeamsService = TeamsService;
exports.TeamsService = TeamsService = TeamsService_1 = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, mongoose_1.InjectModel)(team_schema_1.Team.name)),
    __param(1, (0, mongoose_1.InjectModel)(user_schema_1.User.name)),
    __metadata("design:paramtypes", [mongoose_2.Model,
        mongoose_2.Model])
], TeamsService);
//# sourceMappingURL=teams.service.js.map