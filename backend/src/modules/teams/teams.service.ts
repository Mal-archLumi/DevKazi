import { 
  Injectable, 
  NotFoundException, 
  ForbiddenException, 
  BadRequestException,
  InternalServerErrorException 
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
  constructor(
    @InjectModel(Team.name) private teamModel: Model<TeamDocument>,
    @InjectModel(User.name) private userModel: Model<UserDocument>,
  ) {}

  async create(createTeamDto: CreateTeamDto, userId: string): Promise<Team> {
    try {
      const user = await this.userModel.findById(userId);
      if (!user) {
        throw new NotFoundException('User not found');
      }

      const teamData = {
        ...createTeamDto,
        members: [
          {
            user: new Types.ObjectId(userId),
            role: TeamRole.OWNER,
            joinedAt: new Date(),
          },
        ],
        settings: {
          isPublic: createTeamDto.isPublic ?? true,
          allowJoinRequests: createTeamDto.allowJoinRequests ?? true,
          requireApproval: createTeamDto.requireApproval ?? true,
        },
      };

      const team = new this.teamModel(teamData);
      return await team.save();
    } catch (error) {
      if (error instanceof NotFoundException) {
        throw error;
      }
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

      if (search) {
        query = query.find({
          $or: [
            { name: { $regex: search, $options: 'i' } },
            { description: { $regex: search, $options: 'i' } },
            { projectIdea: { $regex: search, $options: 'i' } },
            { tags: { $in: [new RegExp(search, 'i')] } },
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

      return team as Team;
    } catch (error) {
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

      const userMembership = team.members.find(member => 
        (member.user as Types.ObjectId).toString() === userId && 
        [TeamRole.OWNER, TeamRole.ADMIN].includes(member.role)
      );

      if (!userMembership) {
        throw new ForbiddenException('Only team owners or admins can update the team');
      }

      const updatedTeam = await this.teamModel
        .findByIdAndUpdate(id, updateTeamDto, { new: true, runValidators: true })
        .exec();
      
      if (!updatedTeam) {
        throw new NotFoundException('Team not found after update');
      }

      return updatedTeam as Team;
    } catch (error) {
      if (error instanceof NotFoundException || 
          error instanceof ForbiddenException || 
          error instanceof BadRequestException) {
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

      const userMembership = team.members.find(member => 
        (member.user as Types.ObjectId).toString() === userId && 
        member.role === TeamRole.OWNER
      );

      if (!userMembership) {
        throw new ForbiddenException('Only team owner can delete the team');
      }

      const result = await this.teamModel.findByIdAndDelete(id).exec();
      if (!result) {
        throw new NotFoundException('Team not found during deletion');
      }
    } catch (error) {
      if (error instanceof NotFoundException || 
          error instanceof ForbiddenException || 
          error instanceof BadRequestException) {
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

      // Check if inviter is owner or admin
      const inviterMembership = team.members.find(member => 
        (member.user as Types.ObjectId).toString() === inviterId && 
        [TeamRole.OWNER, TeamRole.ADMIN].includes(member.role)
      );

      if (!inviterMembership) {
        throw new ForbiddenException('Only team owners or admins can invite members');
      }

      let user: UserDocument | null = null;
      if (inviteMemberDto.userId) {
        if (!Types.ObjectId.isValid(inviteMemberDto.userId)) {
          throw new BadRequestException('Invalid user ID');
        }
        user = await this.userModel.findById(inviteMemberDto.userId);
      } else if (inviteMemberDto.email) {
        user = await this.userModel.findOne({ email: inviteMemberDto.email });
      }

      if (!user) {
        throw new NotFoundException('User not found');
      }

      // Check if user is already a member
      const isAlreadyMember = team.members.some(member => 
        (member.user as Types.ObjectId).toString() === (user!._id as Types.ObjectId).toString()
      );
      if (isAlreadyMember) {
        throw new BadRequestException('User is already a team member');
      }

      // Check if user is already invited
      const isAlreadyInvited = team.pendingInvites.some(invite => 
        (invite as Types.ObjectId).toString() === (user!._id as Types.ObjectId).toString()
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
      return await team.save();
    } catch (error) {
      if (error instanceof NotFoundException || 
          error instanceof ForbiddenException || 
          error instanceof BadRequestException) {
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

      // Check if team is accepting join requests
      if (!team.settings.allowJoinRequests) {
        throw new ForbiddenException('This team is not accepting join requests');
      }

      // Check if user is already a member
      const isAlreadyMember = team.members.some(member => 
        (member.user as Types.ObjectId).toString() === userId
      );
      if (isAlreadyMember) {
        throw new BadRequestException('You are already a member of this team');
      }

      // Check if already requested to join
      const hasPendingRequest = team.joinRequests.some(request => 
        (request.user as Types.ObjectId).toString() === userId
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
        message: message || 'I would like to join your team',
        createdAt: new Date(),
      });

      return await team.save();
    } catch (error) {
      if (error instanceof NotFoundException || 
          error instanceof ForbiddenException || 
          error instanceof BadRequestException) {
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

      // Check if approver is owner or admin
      const approverMembership = team.members.find(member => 
        (member.user as Types.ObjectId).toString() === approverId && 
        [TeamRole.OWNER, TeamRole.ADMIN].includes(member.role)
      );

      if (!approverMembership) {
        throw new ForbiddenException('Only team owners or admins can respond to join requests');
      }

      // Find and remove the join request
      const requestIndex = team.joinRequests.findIndex(request => 
        (request.user as Types.ObjectId).toString() === requestUserId
      );
      if (requestIndex === -1) {
        throw new NotFoundException('Join request not found');
      }

      team.joinRequests.splice(requestIndex, 1);

      // If accepted, add as member
      if (accept) {
        // Check team size limit
        if (team.members.length >= team.maxMembers) {
          throw new BadRequestException('Team has reached maximum member limit');
        }

        team.members.push({
          user: new Types.ObjectId(requestUserId),
          role: TeamRole.MEMBER,
          joinedAt: new Date(),
        });
      }

      return await team.save();
    } catch (error) {
      if (error instanceof NotFoundException || 
          error instanceof ForbiddenException || 
          error instanceof BadRequestException) {
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

      // Check if remover is owner or admin, or if they're removing themselves
      const removerMembership = team.members.find(member => 
        (member.user as Types.ObjectId).toString() === removerId
      );
      
      if (!removerMembership) {
        throw new ForbiddenException('You are not a member of this team');
      }

      const isSelfRemoval = removerId === memberId;
      const isOwnerOrAdmin = [TeamRole.OWNER, TeamRole.ADMIN].includes(removerMembership.role);

      if (!isSelfRemoval && !isOwnerOrAdmin) {
        throw new ForbiddenException('Only team owners or admins can remove other members');
      }

      // Prevent owner from removing themselves if they're the only owner
      if (isSelfRemoval && removerMembership.role === TeamRole.OWNER) {
        const otherOwners = team.members.filter(member => 
          member.role === TeamRole.OWNER && 
          (member.user as Types.ObjectId).toString() !== memberId
        );
        if (otherOwners.length === 0) {
          throw new BadRequestException('Team must have at least one owner. Transfer ownership first.');
        }
      }

      // Remove member
      const memberIndex = team.members.findIndex(member => 
        (member.user as Types.ObjectId).toString() === memberId
      );
      if (memberIndex === -1) {
        throw new NotFoundException('Member not found in team');
      }

      team.members.splice(memberIndex, 1);
      return await team.save();
    } catch (error) {
      if (error instanceof NotFoundException || 
          error instanceof ForbiddenException || 
          error instanceof BadRequestException) {
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
        query.requiredSkills = { $in: skills };
      }

      if (search) {
        query.$or = [
          { name: { $regex: search, $options: 'i' } },
          { description: { $regex: search, $options: 'i' } },
          { projectIdea: { $regex: search, $options: 'i' } },
          { tags: { $in: [new RegExp(search, 'i')] } },
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
      throw new InternalServerErrorException('Failed to search teams');
    }
  }
}