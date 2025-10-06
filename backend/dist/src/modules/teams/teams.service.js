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
    isUserOwnerOrAdmin(team, userId) {
        const member = team.members.find(m => {
            const memberUserId = this.getUserId(m.user);
            return memberUserId === userId;
        });
        return member ? [team_schema_1.TeamRole.OWNER, team_schema_1.TeamRole.ADMIN].includes(member.role) : false;
    }
    isUserOwner(team, userId) {
        const member = team.members.find(m => {
            const memberUserId = this.getUserId(m.user);
            return memberUserId === userId;
        });
        return member ? member.role === team_schema_1.TeamRole.OWNER : false;
    }
    async create(createTeamDto, userId) {
        try {
            const user = await this.userModel.findById(userId);
            if (!user) {
                throw new common_1.NotFoundException('User not found');
            }
            const teamData = {
                ...createTeamDto,
                members: [{
                        user: new mongoose_2.Types.ObjectId(userId),
                        role: team_schema_1.TeamRole.OWNER,
                        joinedAt: new Date(),
                    }],
                settings: {
                    isPublic: createTeamDto.isPublic ?? true,
                    allowJoinRequests: createTeamDto.allowJoinRequests ?? true,
                    requireApproval: createTeamDto.requireApproval ?? true,
                },
                status: team_schema_1.TeamStatus.ACTIVE,
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
    async findAll(page = 1, limit = 10, search) {
        try {
            const skip = (page - 1) * limit;
            let query = this.teamModel
                .find({ status: team_schema_1.TeamStatus.ACTIVE })
                .populate('members.user', 'name email avatar skills')
                .sort({ createdAt: -1 });
            if (search && search.trim()) {
                query = query.find({
                    $or: [
                        { name: { $regex: search.trim(), $options: 'i' } },
                        { description: { $regex: search.trim(), $options: 'i' } },
                        { projectIdea: { $regex: search.trim(), $options: 'i' } },
                        { tags: { $in: [new RegExp(search.trim(), 'i')] } },
                    ],
                });
            }
            const [teams, total] = await Promise.all([
                query.skip(skip).limit(limit).exec(),
                this.teamModel.countDocuments(query.getFilter()),
            ]);
            const totalPages = Math.ceil(total / limit);
            return {
                teams: teams,
                total,
                page,
                totalPages
            };
        }
        catch (error) {
            this.logger.error(`Failed to fetch teams: ${error.message}`);
            throw new common_1.InternalServerErrorException('Failed to fetch teams');
        }
    }
    async findOne(id) {
        try {
            if (!mongoose_2.Types.ObjectId.isValid(id)) {
                throw new common_1.BadRequestException('Invalid team ID');
            }
            const team = await this.teamModel
                .findById(id)
                .populate('members.user', 'name email avatar skills education experience')
                .populate('pendingInvites', 'name email')
                .populate('joinRequests.user', 'name email avatar skills')
                .exec();
            if (!team) {
                throw new common_1.NotFoundException('Team not found');
            }
            if (team.status !== team_schema_1.TeamStatus.ACTIVE) {
                throw new common_1.NotFoundException('Team not found or inactive');
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
            if (!this.isUserOwnerOrAdmin(team, userId)) {
                throw new common_1.ForbiddenException('Only team owners or admins can update the team');
            }
            const updatedTeam = await this.teamModel
                .findByIdAndUpdate(id, updateTeamDto, {
                new: true,
                runValidators: true
            })
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
            if (!this.isUserOwnerOrAdmin(team, inviterId)) {
                throw new common_1.ForbiddenException('Only team owners or admins can invite members');
            }
            let user = null;
            if (inviteMemberDto.userId) {
                if (!mongoose_2.Types.ObjectId.isValid(inviteMemberDto.userId)) {
                    throw new common_1.BadRequestException('Invalid user ID');
                }
                user = await this.userModel.findById(inviteMemberDto.userId);
            }
            else if (inviteMemberDto.email) {
                user = await this.userModel.findOne({
                    email: inviteMemberDto.email.toLowerCase().trim()
                });
            }
            else {
                throw new common_1.BadRequestException('Either userId or email must be provided');
            }
            if (!user) {
                throw new common_1.NotFoundException('User not found');
            }
            const targetUserId = user._id.toString();
            const isAlreadyMember = team.members.some(member => this.getUserId(member.user) === targetUserId);
            if (isAlreadyMember) {
                throw new common_1.BadRequestException('User is already a team member');
            }
            const isAlreadyInvited = team.pendingInvites.some(invite => this.getUserId(invite) === targetUserId);
            if (isAlreadyInvited) {
                throw new common_1.BadRequestException('User is already invited to the team');
            }
            if (team.members.length >= team.maxMembers) {
                throw new common_1.BadRequestException('Team has reached maximum member limit');
            }
            team.pendingInvites.push(user._id);
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
    async joinTeam(teamId, userId, message) {
        try {
            if (!mongoose_2.Types.ObjectId.isValid(teamId)) {
                throw new common_1.BadRequestException('Invalid team ID');
            }
            const team = await this.teamModel.findById(teamId);
            if (!team) {
                throw new common_1.NotFoundException('Team not found');
            }
            if (!team.settings.isPublic || !team.settings.allowJoinRequests) {
                throw new common_1.ForbiddenException('This team is not accepting join requests');
            }
            const isAlreadyMember = team.members.some(member => this.getUserId(member.user) === userId);
            if (isAlreadyMember) {
                throw new common_1.BadRequestException('You are already a member of this team');
            }
            const hasPendingRequest = team.joinRequests.some(request => this.getUserId(request.user) === userId);
            if (hasPendingRequest) {
                throw new common_1.BadRequestException('You already have a pending join request');
            }
            if (team.members.length >= team.maxMembers) {
                throw new common_1.BadRequestException('Team has reached maximum member limit');
            }
            team.joinRequests.push({
                user: new mongoose_2.Types.ObjectId(userId),
                message: (message || 'I would like to join your team').trim(),
                createdAt: new Date(),
            });
            const updatedTeam = await team.save();
            this.logger.log(`Join request submitted to team ${teamId} by user: ${userId}`);
            return updatedTeam;
        }
        catch (error) {
            this.logger.error(`Failed to join team ${teamId}: ${error.message}`);
            if (error instanceof common_1.NotFoundException || error instanceof common_1.ForbiddenException || error instanceof common_1.BadRequestException) {
                throw error;
            }
            throw new common_1.InternalServerErrorException('Failed to join team');
        }
    }
    async respondToJoinRequest(teamId, requestUserId, approverId, accept) {
        try {
            if (!mongoose_2.Types.ObjectId.isValid(teamId) || !mongoose_2.Types.ObjectId.isValid(requestUserId)) {
                throw new common_1.BadRequestException('Invalid team ID or user ID');
            }
            const team = await this.teamModel.findById(teamId);
            if (!team) {
                throw new common_1.NotFoundException('Team not found');
            }
            if (!this.isUserOwnerOrAdmin(team, approverId)) {
                throw new common_1.ForbiddenException('Only team owners or admins can respond to join requests');
            }
            const requestIndex = team.joinRequests.findIndex(request => this.getUserId(request.user) === requestUserId);
            if (requestIndex === -1) {
                throw new common_1.NotFoundException('Join request not found');
            }
            team.joinRequests.splice(requestIndex, 1);
            if (accept) {
                if (team.members.length >= team.maxMembers) {
                    throw new common_1.BadRequestException('Team has reached maximum member limit');
                }
                team.members.push({
                    user: new mongoose_2.Types.ObjectId(requestUserId),
                    role: team_schema_1.TeamRole.MEMBER,
                    joinedAt: new Date(),
                });
            }
            const updatedTeam = await team.save();
            this.logger.log(`Join request ${accept ? 'accepted' : 'rejected'} for team ${teamId}, user: ${requestUserId}`);
            return updatedTeam;
        }
        catch (error) {
            this.logger.error(`Failed to respond to join request for team ${teamId}: ${error.message}`);
            if (error instanceof common_1.NotFoundException || error instanceof common_1.ForbiddenException || error instanceof common_1.BadRequestException) {
                throw error;
            }
            throw new common_1.InternalServerErrorException('Failed to respond to join request');
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
            const removerMembership = team.members.find(member => this.getUserId(member.user) === removerId);
            if (!removerMembership) {
                throw new common_1.ForbiddenException('You are not a member of this team');
            }
            const isSelfRemoval = removerId === memberId;
            const isOwnerOrAdmin = [team_schema_1.TeamRole.OWNER, team_schema_1.TeamRole.ADMIN].includes(removerMembership.role);
            if (!isSelfRemoval && !isOwnerOrAdmin) {
                throw new common_1.ForbiddenException('Only team owners or admins can remove other members');
            }
            if (isSelfRemoval && removerMembership.role === team_schema_1.TeamRole.OWNER) {
                const otherOwners = team.members.filter(member => member.role === team_schema_1.TeamRole.OWNER &&
                    this.getUserId(member.user) !== memberId);
                if (otherOwners.length === 0) {
                    throw new common_1.BadRequestException('Team must have at least one owner. Transfer ownership first.');
                }
            }
            const memberIndex = team.members.findIndex(member => this.getUserId(member.user) === memberId);
            if (memberIndex === -1) {
                throw new common_1.NotFoundException('Member not found in team');
            }
            team.members.splice(memberIndex, 1);
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
                status: team_schema_1.TeamStatus.ACTIVE,
            })
                .populate('members.user', 'name email avatar')
                .sort({ updatedAt: -1 })
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
    async searchTeams(skills, search, page = 1, limit = 10) {
        try {
            const skip = (page - 1) * limit;
            const query = { status: team_schema_1.TeamStatus.ACTIVE };
            if (skills && skills.length > 0) {
                const validSkills = skills.filter(skill => skill && skill.trim().length > 0);
                if (validSkills.length > 0) {
                    query.requiredSkills = { $in: validSkills };
                }
            }
            if (search && search.trim()) {
                const searchTerm = search.trim();
                query.$or = [
                    { name: { $regex: searchTerm, $options: 'i' } },
                    { description: { $regex: searchTerm, $options: 'i' } },
                    { projectIdea: { $regex: searchTerm, $options: 'i' } },
                    { tags: { $in: [new RegExp(searchTerm, 'i')] } },
                ];
            }
            const [teams, total] = await Promise.all([
                this.teamModel
                    .find(query)
                    .populate('members.user', 'name email avatar skills')
                    .skip(skip)
                    .limit(limit)
                    .sort({ createdAt: -1 })
                    .exec(),
                this.teamModel.countDocuments(query),
            ]);
            const totalPages = Math.ceil(total / limit);
            return {
                teams: teams,
                total,
                page,
                totalPages
            };
        }
        catch (error) {
            this.logger.error(`Failed to search teams: ${error.message}`);
            throw new common_1.InternalServerErrorException('Failed to search teams');
        }
    }
    async verifyTeamMembership(teamId, userId) {
        const team = await this.getTeamById(teamId);
        const isMember = team.members.some(member => member.user.toString() === userId);
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
    async verifyTeamAdmin(teamId, userId) {
        const team = await this.getTeamById(teamId);
        const isAdmin = team.members.some(member => member.user.toString() === userId && ['owner', 'admin'].includes(member.role));
        if (!isAdmin) {
            throw new common_1.ForbiddenException('You do not have admin permissions for this team');
        }
        return true;
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