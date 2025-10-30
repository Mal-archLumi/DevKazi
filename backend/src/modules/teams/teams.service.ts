// teams.service.ts
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
import { Team, TeamDocument } from './schemas/team.schema';
import { User, UserDocument } from '../users/schemas/user.schema';
import { CreateTeamDto } from './dto/create-team.dto';
import { UpdateTeamDto } from './dto/update-team.dto';
import { InviteMemberDto } from './dto/invite-member.dto';

interface TeamResponse {
  id: string;
  name: string;
  memberCount: number;
  createdAt: Date;
  lastActivity: Date;
  description?: string; // Added for the new method
  owner?: {
    id: string;
    name: string;
    email: string;
  }; // Added for the new method
  inviteCode?: string; // Added for the new method
  isMember?: boolean; // Added for the new method
}

@Injectable()
export class TeamsService {
  private readonly logger = new Logger(TeamsService.name);

  constructor(
    @InjectModel(Team.name) private teamModel: Model<TeamDocument>,
    @InjectModel(User.name) private userModel: Model<UserDocument>,
  ) {}

  /**
   * Generate a random invite code
   */
  private generateInviteCode(): string {
    return Math.random().toString(36).substring(2, 8).toUpperCase();
  }

  /**
   * Safely extract user ID from any user reference
   */
  private getUserId(userRef: Types.ObjectId | UserDocument | any): string {
    try {
      if (userRef instanceof Types.ObjectId) {
        return userRef.toString();
      }
      
      if (userRef && userRef._id) {
        return (userRef._id as Types.ObjectId).toString();
      }
      
      if (typeof userRef === 'string') {
        return userRef;
      }
      
      return String(userRef);
    } catch (error) {
      this.logger.warn(`Failed to extract user ID from: ${userRef}`);
      throw new BadRequestException('Invalid user reference');
    }
  }

  /**
   * Check if user is owner of team
   */
  private isUserOwner(team: TeamDocument, userId: string): boolean {
    const ownerId = this.getUserId(team.owner);
    return ownerId === userId;
  }

  /**
   * Check if user is member of team
   */
  private isUserMember(team: TeamDocument, userId: string): boolean {
    return team.members.some(member => 
      this.getUserId(member.user) === userId
    );
  }

  async create(createTeamDto: CreateTeamDto, userId: string): Promise<Team> {
    try {
      const user = await this.userModel.findById(userId);
      if (!user) {
        throw new NotFoundException('User not found');
      }

      // Generate unique invite code
      let inviteCode: string;
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
        throw new InternalServerErrorException('Failed to generate unique invite code');
      }

      const teamData = {
        ...createTeamDto,
        owner: new Types.ObjectId(userId),
        members: [{
          user: new Types.ObjectId(userId),
          joinedAt: new Date(),
        }],
        inviteCode: inviteCode!,
        lastActivity: new Date(),
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

  async findOne(id: string): Promise<Team> {
    try {
      if (!Types.ObjectId.isValid(id)) {
        throw new BadRequestException('Invalid team ID');
      }

      const team = await this.teamModel
        .findById(id)
        .populate('owner', 'name email')
        .populate('members.user', 'name email')
        .exec();

      if (!team) {
        throw new NotFoundException('Team not found');
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

      if (!this.isUserOwner(team, userId)) {
        throw new ForbiddenException('Only team owner can update the team');
      }

      const updatedTeam = await this.teamModel
        .findByIdAndUpdate(id, 
          { 
            ...updateTeamDto,
            lastActivity: new Date() 
          }, 
          { 
            new: true, 
            runValidators: true 
          }
        )
        .populate('owner', 'name email')
        .populate('members.user', 'name email')
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

      if (!this.isUserOwner(team, inviterId)) {
        throw new ForbiddenException('Only team owner can invite members');
      }

      const user = await this.userModel.findOne({ 
        email: inviteMemberDto.email.toLowerCase().trim() 
      });

      if (!user) {
        throw new NotFoundException('User not found with this email');
      }

      const targetUserId = (user._id as Types.ObjectId).toString();

      // Check if user is already a member
      const isAlreadyMember = team.members.some(member => 
        this.getUserId(member.user) === targetUserId
      );
      if (isAlreadyMember) {
        throw new BadRequestException('User is already a team member');
      }

      // Add user to members
      team.members.push({
        user: new Types.ObjectId(targetUserId),
        joinedAt: new Date(),
      });

      team.lastActivity = new Date();
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

  async joinTeam(inviteCode: string, userId: string): Promise<Team> {
    try {
      const team = await this.teamModel.findOne({ inviteCode });
      if (!team) {
        throw new NotFoundException('Invalid invite code or team not found');
      }

      // Check if user is already a member
      const isAlreadyMember = team.members.some(member => 
        this.getUserId(member.user) === userId
      );
      if (isAlreadyMember) {
        throw new BadRequestException('You are already a member of this team');
      }

      // Add user to members
      team.members.push({
        user: new Types.ObjectId(userId),
        joinedAt: new Date(),
      });

      team.lastActivity = new Date();
      const updatedTeam = await team.save();
      
      this.logger.log(`User ${userId} joined team ${team._id} using invite code`);
      return updatedTeam;
    } catch (error) {
      this.logger.error(`Failed to join team with code ${inviteCode}: ${error.message}`);
      if (error instanceof NotFoundException || error instanceof BadRequestException) {
        throw error;
      }
      throw new InternalServerErrorException('Failed to join team');
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

      // Check if remover is owner
      if (!this.isUserOwner(team, removerId)) {
        throw new ForbiddenException('Only team owner can remove members');
      }

      // Prevent owner from removing themselves
      if (removerId === memberId) {
        throw new BadRequestException('Owner cannot remove themselves from the team');
      }

      const memberIndex = team.members.findIndex(member => 
        this.getUserId(member.user) === memberId
      );
      if (memberIndex === -1) {
        throw new NotFoundException('Member not found in team');
      }

      team.members.splice(memberIndex, 1);
      team.lastActivity = new Date();
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

  async getUserTeams(userId: string): Promise<TeamResponse[]> {
    try {
      if (!Types.ObjectId.isValid(userId)) {
        throw new BadRequestException('Invalid user ID');
      }

      const teams = await this.teamModel
        .find({
          'members.user': new Types.ObjectId(userId),
        })
        .sort({ lastActivity: -1 })
        .exec();

      return teams.map(team => ({
        id: team._id.toString(),
        name: team.name,
        memberCount: team.members.length,
        createdAt: (team as any).createdAt,
        lastActivity: team.lastActivity,
      }));
    } catch (error) {
      this.logger.error(`Failed to fetch user teams for ${userId}: ${error.message}`);
      if (error instanceof BadRequestException) {
        throw error;
      }
      throw new InternalServerErrorException('Failed to fetch user teams');
    }
  }

  async regenerateInviteCode(teamId: string, userId: string): Promise<Team> {
    try {
      if (!Types.ObjectId.isValid(teamId)) {
        throw new BadRequestException('Invalid team ID');
      }

      const team = await this.teamModel.findById(teamId);
      if (!team) {
        throw new NotFoundException('Team not found');
      }

      if (!this.isUserOwner(team, userId)) {
        throw new ForbiddenException('Only team owner can regenerate invite code');
      }

      // Generate new unique invite code
      let newInviteCode: string;
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
        throw new InternalServerErrorException('Failed to generate unique invite code');
      }

      team.inviteCode = newInviteCode!;
      team.lastActivity = new Date();
      const updatedTeam = await team.save();

      this.logger.log(`Invite code regenerated for team ${teamId} by user: ${userId}`);
      return updatedTeam;
    } catch (error) {
      this.logger.error(`Failed to regenerate invite code for team ${teamId}: ${error.message}`);
      if (error instanceof NotFoundException || error instanceof ForbiddenException || error instanceof BadRequestException) {
        throw error;
      }
      throw new InternalServerErrorException('Failed to regenerate invite code');
    }
  }

  async verifyTeamMembership(teamId: string, userId: string): Promise<boolean> {
    const team = await this.teamModel.findById(teamId);
    if (!team) {
      throw new NotFoundException('Team not found');
    }

    const isMember = this.isUserMember(team, userId);
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

 async findAll(): Promise<any[]> {
  try {
    const teams = await this.teamModel
      .find()
      .populate('owner', 'name email')
      .populate('members.user', 'name email')
      .sort({ lastActivity: -1 })
      .exec();

    return teams.map(team => {
      const owner = team.owner as any; // Populated user or undefined

      return {
        id: team._id.toString(),
        name: team.name,
        description: team.description,
        logoUrl: team.logoUrl,
        memberCount: team.members.length,
        createdAt: (team as any).createdAt,
        lastActivity: team.lastActivity,
        owner: owner
          ? {
              id: owner._id?.toString() || this.getUserId(owner),
              name: owner.name || 'Unknown',
              email: owner.email || 'unknown@example.com',
            }
          : {
              id: 'unknown',
              name: 'Deleted User',
              email: 'deleted@example.com',
            },
      };
    });
  } catch (error) {
    console.log('findAll ERROR:', error.message);
    throw new InternalServerErrorException('Failed to fetch teams');
  }
}


  async getAllTeamsExceptUser(userId: string): Promise<any[]> {
  try {
    if (!Types.ObjectId.isValid(userId)) {
      throw new BadRequestException('Invalid user ID');
    }

    // Get all teams where the user is NOT a member
    const teams = await this.teamModel
      .find({
        'members.user': { $ne: new Types.ObjectId(userId) }
      })
      .populate('owner', 'name email')
      .populate('members.user', 'name email')
      .sort({ lastActivity: -1 })
      .exec();

    return teams.map(team => ({
      id: team._id.toString(),
      name: team.name,
      description: team.description,
      logoUrl: team.logoUrl,
      memberCount: team.members.length,
      createdAt: (team as any).createdAt,
      lastActivity: team.lastActivity,
      owner: {
        id: this.getUserId(team.owner),
        name: (team.owner as any).name,
        email: (team.owner as any).email,
      },
      isMember: false,
    }));
  } catch (error) {
    this.logger.error(`Failed to fetch browse teams for user ${userId}: ${error.message}`);
    if (error instanceof BadRequestException) {
      throw error;
    }
    throw new InternalServerErrorException('Failed to fetch teams');
  }
}
}