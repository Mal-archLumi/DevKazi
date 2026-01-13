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
import { JoinRequest, JoinRequestDocument, JoinRequestStatus } from './schemas/join-request.schema'; // Added import
import { CreateTeamDto } from './dto/create-team.dto';
import { UpdateTeamDto } from './dto/update-team.dto';
import { InviteMemberDto } from './dto/invite-member.dto';

interface TeamResponse {
  id: string;
  name: string;
  memberCount: number;
  createdAt: Date;
  lastActivity: Date;
  description?: string;
  owner?: {
    id: string;
    name: string;
    email: string;
  };
  inviteCode?: string;
  isMember?: boolean;
}

@Injectable()
export class TeamsService {
  private readonly logger = new Logger(TeamsService.name);
  joinRequestModel: any;

  constructor(
    @InjectModel(Team.name) private teamModel: Model<TeamDocument>,
    @InjectModel(User.name) private userModel: Model<UserDocument>,
  ) {}

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

      const teamData = {
        ...createTeamDto,
        owner: new Types.ObjectId(userId),
        members: [{
          user: new Types.ObjectId(userId),
          joinedAt: new Date(),
        }],
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

  async requestToJoinTeam(teamId: string, userId: string): Promise<any> {
    // This method is now handled by JoinRequestsService
    throw new BadRequestException('Use join-requests endpoint to request joining a team');
  }

  async getUserTeams(userId: string): Promise<Team[]> {
    try {
      if (!Types.ObjectId.isValid(userId)) {
        throw new BadRequestException('Invalid user ID');
      }

      const teams = await this.teamModel
        .find({
          'members.user': new Types.ObjectId(userId),
        })
        .populate('owner', 'name email')
        .populate('members.user', 'name email')
        .sort({ lastActivity: -1 })
        .exec();

      return teams;
    } catch (error) {
      this.logger.error(`Failed to fetch user teams for ${userId}: ${error.message}`);
      if (error instanceof BadRequestException) {
        throw error;
      }
      throw new InternalServerErrorException('Failed to fetch user teams');
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

    // Check for pending join requests for each team
    const teamsWithRequestStatus = await Promise.all(
      teams.map(async (team) => {
        const joinRequest = await this.joinRequestModel.findOne({
          team: team._id,
          user: new Types.ObjectId(userId),
          status: JoinRequestStatus.PENDING,
        });

        return {
          id: team._id.toString(),
          name: team.name,
          description: team.description,
          logoUrl: team.logoUrl,
          memberCount: team.members.length,
          maxMembers: team.maxMembers || 4,
          createdAt: (team as any).createdAt,
          lastActivity: team.lastActivity,
          owner: {
            id: this.getUserId(team.owner),
            name: (team.owner as any).name,
            email: (team.owner as any).email,
          },
          isMember: false,
          hasPendingRequest: !!joinRequest,
        };
      })
    );

    return teamsWithRequestStatus;
  } catch (error) {
    this.logger.error(`Failed to fetch browse teams for user ${userId}: ${error.message}`);
    if (error instanceof BadRequestException) {
      throw error;
    }
    throw new InternalServerErrorException('Failed to fetch teams');
  }
}
async searchUserTeams(userId: string, query: string): Promise<Team[]> {
  try {
    if (!Types.ObjectId.isValid(userId)) {
      throw new BadRequestException('Invalid user ID');
    }

    const searchRegex = new RegExp(query, 'i'); // case-insensitive search
    
    const teams = await this.teamModel
      .find({
        'members.user': new Types.ObjectId(userId),
        $or: [
          { name: { $regex: searchRegex } },
          { description: { $regex: searchRegex } }
        ]
      })
      .populate('owner', 'name email')
      .populate('members.user', 'name email')
      .sort({ lastActivity: -1 })
      .exec();

    return teams;
  } catch (error) {
    this.logger.error(`Failed to search user teams for ${userId}: ${error.message}`);
    if (error instanceof BadRequestException) {
      throw error;
    }
    throw new InternalServerErrorException('Failed to search teams');
  }
}

async searchAllTeams(query: string): Promise<Team[]> {
  try {
    const searchRegex = new RegExp(query, 'i'); // case-insensitive search
    
    const teams = await this.teamModel
      .find({
        $or: [
          { name: { $regex: searchRegex } },
          { description: { $regex: searchRegex } }
        ]
      })
      .populate('owner', 'name email')
      .populate('members.user', 'name email')
      .sort({ lastActivity: -1 })
      .exec();

    return teams;
  } catch (error) {
    this.logger.error(`Failed to search all teams: ${error.message}`);
    throw new InternalServerErrorException('Failed to search teams');
  }
}

async searchTeamsExceptUser(userId: string, query: string): Promise<Team[]> {
  try {
    if (!Types.ObjectId.isValid(userId)) {
      throw new BadRequestException('Invalid user ID');
    }

    const searchRegex = new RegExp(query, 'i');
    
    const teams = await this.teamModel
      .find({
        'members.user': { $ne: new Types.ObjectId(userId) },
        $or: [
          { name: { $regex: searchRegex } },
          { description: { $regex: searchRegex } }
        ]
      })
      .populate('owner', 'name email')
      .populate('members.user', 'name email')
      .sort({ lastActivity: -1 })
      .exec();

    return teams;
  } catch (error) {
    this.logger.error(`Failed to search browse teams for user ${userId}: ${error.message}`);
    if (error instanceof BadRequestException) {
      throw error;
    }
    throw new InternalServerErrorException('Failed to search teams');
  }
}

async leaveTeam(teamId: string, userId: string): Promise<void> {
  try {
    if (!Types.ObjectId.isValid(teamId)) {
      throw new BadRequestException('Invalid team ID');
    }

    const team = await this.teamModel.findById(teamId);
    if (!team) {
      throw new NotFoundException('Team not found');
    }

    // Check if user is a member
    const isMember = this.isUserMember(team, userId);
    if (!isMember) {
      throw new BadRequestException('You are not a member of this team');
    }

    const isOwner = this.isUserOwner(team, userId);
    const memberCount = team.members.length;

    // REMOVED: The old check that prevented owners from leaving
    // if (this.isUserOwner(team, userId)) {
    //   throw new BadRequestException('Team owner cannot leave the team. Please transfer ownership or delete the team.');
    // }

    // NEW: Handle owner leaving
    if (isOwner) {
      // If owner is the only member, delete the team
      if (memberCount === 1) {
        await this.teamModel.findByIdAndDelete(teamId).exec();
        this.logger.log(`Team ${teamId} deleted because owner was the only member`);
        return;
      }
      
      // If there are other members, transfer ownership to the next member
      // Find a member who is NOT the owner
      const otherMembers = team.members.filter(member => 
        this.getUserId(member.user) !== userId
      );
      
      if (otherMembers.length === 0) {
        throw new BadRequestException('No other members to transfer ownership to');
      }
      
      // Transfer ownership to the first other member (earliest joiner)
      const newOwner = otherMembers[0].user;
      team.owner = newOwner;
      
      // Remove user from members
      team.members = team.members.filter(member => 
        this.getUserId(member.user) !== userId
      );
      
      team.lastActivity = new Date();
      await team.save();
      
      this.logger.log(`Ownership of team ${team._id} transferred from ${userId} to ${this.getUserId(newOwner)}`);
      return;
    }

    // For non-owners, simply remove from members
    team.members = team.members.filter(member => 
      this.getUserId(member.user) !== userId
    );

    // Update last activity
    team.lastActivity = new Date();
    
    // Save the team
    await team.save();
    
    this.logger.log(`User ${userId} left team ${team._id}. Members: ${memberCount} → ${team.members.length}`);
    
    // IMPORTANT: We DON'T delete user messages when they leave
    // Messages should remain as historical record
    // The frontend will handle "Deleted User" display
    
  } catch (error) {
    this.logger.error(`Failed to leave team ${teamId}: ${error.message}`);
    if (error instanceof NotFoundException || error instanceof BadRequestException) {
      throw error;
    }
    throw new InternalServerErrorException('Failed to leave team');
  }
}
}
