import { 
  Injectable, 
  NotFoundException, 
  ForbiddenException, 
  BadRequestException,
  InternalServerErrorException,
  Logger 
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Team, TeamDocument, TeamRole, TeamStatus } from './schemas/team.schema';
import { User, UserDocument } from '../users/schemas/user.schema';
import { CreateTeamDto } from './dto/create-team.dto';
import { UpdateTeamDto } from './dto/update-team.dto';
import { InviteMemberDto } from './dto/invite-member.dto';

@Injectable()
export class TeamsService {
  private readonly logger = new Logger(TeamsService.name);

  constructor(
    @InjectModel(Team.name) private teamModel: Model<TeamDocument>,
    @InjectModel(User.name) private userModel: Model<UserDocument>,
  ) {}

  /**
   * CRITICAL FIX: Safely extract user ID from any user reference
   * This handles ObjectId, populated UserDocument, and string IDs
   */
  private getUserId(userRef: Types.ObjectId | UserDocument | any): string {
    try {
      // If it's already an ObjectId
      if (userRef instanceof Types.ObjectId) {
        return userRef.toString();
      }
      
      // If it's a UserDocument with _id
      if (userRef && userRef._id) {
        return (userRef._id as Types.ObjectId).toString();
      }
      
      // If it's already a string
      if (typeof userRef === 'string') {
        return userRef;
      }
      
      // Last resort - convert to string
      return String(userRef);
    } catch (error) {
      this.logger.warn(`Failed to extract user ID from: ${userRef}`);
      throw new BadRequestException('Invalid user reference');
    }
  }

  /**
   * CRITICAL FIX: Check if user is owner or admin of team
   * Uses direct comparison with proper type handling
   */
  private isUserOwnerOrAdmin(team: TeamDocument, userId: string): boolean {
    const member = team.members.find(m => {
      const memberUserId = this.getUserId(m.user);
      return memberUserId === userId;
    });
    
    return member ? [TeamRole.OWNER, TeamRole.ADMIN].includes(member.role) : false;
  }

  /**
   * CRITICAL FIX: Check if user is owner of team
   * Strict verification for delete operations
   */
  private isUserOwner(team: TeamDocument, userId: string): boolean {
    const member = team.members.find(m => {
      const memberUserId = this.getUserId(m.user);
      return memberUserId === userId;
    });
    
    return member ? member.role === TeamRole.OWNER : false;
  }

  async create(createTeamDto: CreateTeamDto, userId: string): Promise<Team> {
    try {
      const user = await this.userModel.findById(userId);
      if (!user) {
        throw new NotFoundException('User not found');
      }

      const teamData = {
        ...createTeamDto,
        members: [{
          user: new Types.ObjectId(userId),
          role: TeamRole.OWNER,
          joinedAt: new Date(),
        }],
        settings: {
          isPublic: createTeamDto.isPublic ?? true,
          allowJoinRequests: createTeamDto.allowJoinRequests ?? true,
          requireApproval: createTeamDto.requireApproval ?? true,
        },
        status: TeamStatus.ACTIVE,
      };

      const team = new this.teamModel(teamData);
      const savedTeam = await team.save();
      
      this.logger.log(`Team created: ${savedTeam._id} by user: ${userId}`);
      return savedTeam;
    } catch (error) {
      this.logger.error(`Create team error: ${error.message}`);
      if (error instanceof NotFoundException) throw error;
      throw new InternalServerErrorException('Failed to create team');
    }
  }

  async findAll(
    page: number = 1, 
    limit: number = 10, 
    search?: string
  ): Promise<{ teams: Team[]; total: number; page: number; totalPages: number }> {
    try {
      const skip = (page - 1) * limit;
      let query = this.teamModel
        .find({ status: TeamStatus.ACTIVE })
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
        teams: teams as Team[], 
        total, 
        page, 
        totalPages 
      };
    } catch (error) {
      this.logger.error(`Failed to fetch teams: ${error.message}`);
      throw new InternalServerErrorException('Failed to fetch teams');
    }
  }

  async findOne(id: string): Promise<Team> {
    try {
      if (!Types.ObjectId.isValid(id)) {
        throw new BadRequestException('Invalid team ID');
      }

      const team = await this.teamModel
        .findById(id)
        .populate('members.user', 'name email avatar skills education experience')
        .populate('pendingInvites', 'name email')
        .populate('joinRequests.user', 'name email avatar skills')
        .exec();

      if (!team) {
        throw new NotFoundException('Team not found');
      }

      if (team.status !== TeamStatus.ACTIVE) {
        throw new NotFoundException('Team not found or inactive');
      }

      return team;
    } catch (error) {
      this.logger.error(`Failed to fetch team ${id}: ${error.message}`);
      if (error instanceof NotFoundException || error instanceof BadRequestException) {
        throw error;
      }
      throw new InternalServerErrorException('Failed to fetch team');
    }
  }

  async update(id: string, updateTeamDto: UpdateTeamDto, userId: string): Promise<Team> {
    try {
      if (!Types.ObjectId.isValid(id)) {
        throw new BadRequestException('Invalid team ID');
      }

      const team = await this.teamModel.findById(id);
      if (!team) {
        throw new NotFoundException('Team not found');
      }

      // SECURITY FIX: This should now properly return 403 for non-owners/admins
      if (!this.isUserOwnerOrAdmin(team, userId)) {
        throw new ForbiddenException('Only team owners or admins can update the team');
      }

      const updatedTeam = await this.teamModel
        .findByIdAndUpdate(id, updateTeamDto, { 
          new: true, 
          runValidators: true 
        })
        .exec();
      
      if (!updatedTeam) {
        throw new NotFoundException('Team not found after update');
      }

      this.logger.log(`Team updated: ${id} by user: ${userId}`);
      return updatedTeam;
    } catch (error) {
      this.logger.error(`Failed to update team ${id}: ${error.message}`);
      if (error instanceof NotFoundException || error instanceof ForbiddenException || error instanceof BadRequestException) {
        throw error;
      }
      throw new InternalServerErrorException('Failed to update team');
    }
  }

  async remove(id: string, userId: string): Promise<void> {
    try {
      if (!Types.ObjectId.isValid(id)) {
        throw new BadRequestException('Invalid team ID');
      }

      const team = await this.teamModel.findById(id);
      if (!team) {
        throw new NotFoundException('Team not found');
      }

      // SECURITY FIX: This should now properly return 403 for non-owners
      if (!this.isUserOwner(team, userId)) {
        throw new ForbiddenException('Only team owner can delete the team');
      }

      const result = await this.teamModel.findByIdAndDelete(id).exec();
      if (!result) {
        throw new NotFoundException('Team not found during deletion');
      }

      this.logger.log(`Team deleted: ${id} by user: ${userId}`);
    } catch (error) {
      this.logger.error(`Failed to delete team ${id}: ${error.message}`);
      if (error instanceof NotFoundException || error instanceof ForbiddenException || error instanceof BadRequestException) {
        throw error;
      }
      throw new InternalServerErrorException('Failed to delete team');
    }
  }

  async inviteMember(teamId: string, inviteMemberDto: InviteMemberDto, inviterId: string): Promise<Team> {
    try {
      if (!Types.ObjectId.isValid(teamId)) {
        throw new BadRequestException('Invalid team ID');
      }

      const team = await this.teamModel.findById(teamId);
      if (!team) {
        throw new NotFoundException('Team not found');
      }

      // SECURITY FIX: Only owners/admins can invite
      if (!this.isUserOwnerOrAdmin(team, inviterId)) {
        throw new ForbiddenException('Only team owners or admins can invite members');
      }

      let user: UserDocument | null = null;
      
      if (inviteMemberDto.userId) {
        if (!Types.ObjectId.isValid(inviteMemberDto.userId)) {
          throw new BadRequestException('Invalid user ID');
        }
        user = await this.userModel.findById(inviteMemberDto.userId);
      } else if (inviteMemberDto.email) {
        user = await this.userModel.findOne({ 
          email: inviteMemberDto.email.toLowerCase().trim() 
        });
      } else {
        throw new BadRequestException('Either userId or email must be provided');
      }

      if (!user) {
        throw new NotFoundException('User not found');
      }

      // Type-safe user ID access
      const targetUserId = (user._id as Types.ObjectId).toString();

      // Check if user is already a member
      const isAlreadyMember = team.members.some(member => 
        this.getUserId(member.user) === targetUserId
      );
      if (isAlreadyMember) {
        throw new BadRequestException('User is already a team member');
      }

      // Check if user is already invited
      const isAlreadyInvited = team.pendingInvites.some(invite => 
        this.getUserId(invite) === targetUserId
      );
      if (isAlreadyInvited) {
        throw new BadRequestException('User is already invited to the team');
      }

      // Check team size limit
      if (team.members.length >= team.maxMembers) {
        throw new BadRequestException('Team has reached maximum member limit');
      }

      // Add to pending invites
      team.pendingInvites.push(user._id as Types.ObjectId);
      const updatedTeam = await team.save();
      
      this.logger.log(`Member invited to team ${teamId}: ${targetUserId} by user: ${inviterId}`);
      return updatedTeam;
    } catch (error) {
      this.logger.error(`Failed to invite member to team ${teamId}: ${error.message}`);
      if (error instanceof NotFoundException || error instanceof ForbiddenException || error instanceof BadRequestException) {
        throw error;
      }
      throw new InternalServerErrorException('Failed to invite member');
    }
  }

  async joinTeam(teamId: string, userId: string, message?: string): Promise<Team> {
    try {
      if (!Types.ObjectId.isValid(teamId)) {
        throw new BadRequestException('Invalid team ID');
      }

      const team = await this.teamModel.findById(teamId);
      if (!team) {
        throw new NotFoundException('Team not found');
      }

      if (!team.settings.isPublic || !team.settings.allowJoinRequests) {
        throw new ForbiddenException('This team is not accepting join requests');
      }

      // Check if user is already a member
      const isAlreadyMember = team.members.some(member => 
        this.getUserId(member.user) === userId
      );
      if (isAlreadyMember) {
        throw new BadRequestException('You are already a member of this team');
      }

      // Check if already requested to join
      const hasPendingRequest = team.joinRequests.some(request => 
        this.getUserId(request.user) === userId
      );
      if (hasPendingRequest) {
        throw new BadRequestException('You already have a pending join request');
      }

      // Check team size limit
      if (team.members.length >= team.maxMembers) {
        throw new BadRequestException('Team has reached maximum member limit');
      }

      // Add join request
      team.joinRequests.push({
        user: new Types.ObjectId(userId),
        message: (message || 'I would like to join your team').trim(),
        createdAt: new Date(),
      });

      const updatedTeam = await team.save();
      this.logger.log(`Join request submitted to team ${teamId} by user: ${userId}`);
      return updatedTeam;
    } catch (error) {
      this.logger.error(`Failed to join team ${teamId}: ${error.message}`);
      if (error instanceof NotFoundException || error instanceof ForbiddenException || error instanceof BadRequestException) {
        throw error;
      }
      throw new InternalServerErrorException('Failed to join team');
    }
  }

  async respondToJoinRequest(
    teamId: string, 
    requestUserId: string, 
    approverId: string, 
    accept: boolean
  ): Promise<Team> {
    try {
      if (!Types.ObjectId.isValid(teamId) || !Types.ObjectId.isValid(requestUserId)) {
        throw new BadRequestException('Invalid team ID or user ID');
      }

      const team = await this.teamModel.findById(teamId);
      if (!team) {
        throw new NotFoundException('Team not found');
      }

      // SECURITY FIX: Only owners/admins can respond
      if (!this.isUserOwnerOrAdmin(team, approverId)) {
        throw new ForbiddenException('Only team owners or admins can respond to join requests');
      }

      const requestIndex = team.joinRequests.findIndex(request => 
        this.getUserId(request.user) === requestUserId
      );
      if (requestIndex === -1) {
        throw new NotFoundException('Join request not found');
      }

      team.joinRequests.splice(requestIndex, 1);

      if (accept) {
        if (team.members.length >= team.maxMembers) {
          throw new BadRequestException('Team has reached maximum member limit');
        }

        team.members.push({
          user: new Types.ObjectId(requestUserId),
          role: TeamRole.MEMBER,
          joinedAt: new Date(),
        });
      }

      const updatedTeam = await team.save();
      this.logger.log(`Join request ${accept ? 'accepted' : 'rejected'} for team ${teamId}, user: ${requestUserId}`);
      return updatedTeam;
    } catch (error) {
      this.logger.error(`Failed to respond to join request for team ${teamId}: ${error.message}`);
      if (error instanceof NotFoundException || error instanceof ForbiddenException || error instanceof BadRequestException) {
        throw error;
      }
      throw new InternalServerErrorException('Failed to respond to join request');
    }
  }

  async removeMember(teamId: string, memberId: string, removerId: string): Promise<Team> {
    try {
      if (!Types.ObjectId.isValid(teamId) || !Types.ObjectId.isValid(memberId)) {
        throw new BadRequestException('Invalid team ID or member ID');
      }

      const team = await this.teamModel.findById(teamId);
      if (!team) {
        throw new NotFoundException('Team not found');
      }

      const removerMembership = team.members.find(member => 
        this.getUserId(member.user) === removerId
      );
      
      if (!removerMembership) {
        throw new ForbiddenException('You are not a member of this team');
      }

      const isSelfRemoval = removerId === memberId;
      const isOwnerOrAdmin = [TeamRole.OWNER, TeamRole.ADMIN].includes(removerMembership.role);

      if (!isSelfRemoval && !isOwnerOrAdmin) {
        throw new ForbiddenException('Only team owners or admins can remove other members');
      }

      if (isSelfRemoval && removerMembership.role === TeamRole.OWNER) {
        const otherOwners = team.members.filter(member => 
          member.role === TeamRole.OWNER && 
          this.getUserId(member.user) !== memberId
        );
        if (otherOwners.length === 0) {
          throw new BadRequestException('Team must have at least one owner. Transfer ownership first.');
        }
      }

      const memberIndex = team.members.findIndex(member => 
        this.getUserId(member.user) === memberId
      );
      if (memberIndex === -1) {
        throw new NotFoundException('Member not found in team');
      }

      team.members.splice(memberIndex, 1);
      const updatedTeam = await team.save();
      
      this.logger.log(`Member removed from team ${teamId}: ${memberId} by user: ${removerId}`);
      return updatedTeam;
    } catch (error) {
      this.logger.error(`Failed to remove member from team ${teamId}: ${error.message}`);
      if (error instanceof NotFoundException || error instanceof ForbiddenException || error instanceof BadRequestException) {
        throw error;
      }
      throw new InternalServerErrorException('Failed to remove member');
    }
  }

  async getUserTeams(userId: string): Promise<Team[]> {
    try {
      if (!Types.ObjectId.isValid(userId)) {
        throw new BadRequestException('Invalid user ID');
      }

      const teams = await this.teamModel
        .find({
          'members.user': new Types.ObjectId(userId),
          status: TeamStatus.ACTIVE,
        })
        .populate('members.user', 'name email avatar')
        .sort({ updatedAt: -1 })
        .exec();

      return teams as Team[];
    } catch (error) {
      this.logger.error(`Failed to fetch user teams for ${userId}: ${error.message}`);
      if (error instanceof BadRequestException) {
        throw error;
      }
      throw new InternalServerErrorException('Failed to fetch user teams');
    }
  }

  async searchTeams(
    skills?: string[],
    search?: string,
    page: number = 1,
    limit: number = 10
  ): Promise<{ teams: Team[]; total: number; page: number; totalPages: number }> {
    try {
      const skip = (page - 1) * limit;
      const query: any = { status: TeamStatus.ACTIVE };

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
        teams: teams as Team[], 
        total, 
        page, 
        totalPages 
      };
    } catch (error) {
      this.logger.error(`Failed to search teams: ${error.message}`);
      throw new InternalServerErrorException('Failed to search teams');
    }
  }
  async verifyTeamMembership(teamId: string, userId: string): Promise<boolean> {
  const team = await this.getTeamById(teamId);
  const isMember = team.members.some(member => member.user.toString() === userId);

  if (!isMember) {
    throw new ForbiddenException('You are not a member of this team');
  }

  return true;
}
  async getTeamById(teamId: string): Promise<TeamDocument> {
    const team = await this.teamModel.findById(teamId);
    if (!team) {
      throw new NotFoundException('Team not found');
    }
    return team;
  }

  async verifyTeamAdmin(teamId: string, userId: string): Promise<boolean> {
  const team = await this.getTeamById(teamId);
  const isAdmin = team.members.some(member => 
    member.user.toString() === userId && ['owner', 'admin'].includes(member.role)
  );

  if (!isAdmin) {
    throw new ForbiddenException('You do not have admin permissions for this team');
  }

  return true;
}
}