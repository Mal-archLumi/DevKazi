// join-requests.service.ts
import {
  Injectable,
  BadRequestException,
  NotFoundException,
  Logger,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { JoinRequest, JoinRequestDocument, JoinRequestStatus } from '../schemas/join-request.schema';
import { Team, TeamDocument } from '../schemas/team.schema';
import { TeamsService } from '../teams.service';

@Injectable()
export class JoinRequestsService {
  findOne(requestId: string) {
    throw new Error('Method not implemented.');
  }
  private readonly logger = new Logger(JoinRequestsService.name);

  constructor(
    @InjectModel(JoinRequest.name)
    public joinRequestModel: Model<JoinRequestDocument>,
    @InjectModel(Team.name)
    private teamModel: Model<TeamDocument>,
    private readonly teamsService: TeamsService, 
  ) {}

  async createJoinRequest(
    teamId: string,
    userId: string,
    message?: string,
  ): Promise<JoinRequest> {
    try {
      this.logger.log(`Creating join request for team: ${teamId} by user: ${userId}`);

      // Validate inputs
      if (!teamId || !Types.ObjectId.isValid(teamId)) {
        throw new BadRequestException('Invalid team ID');
      }

      if (!userId || !Types.ObjectId.isValid(userId)) {
        throw new BadRequestException('Invalid user ID');
      }

      const teamObjectId = new Types.ObjectId(teamId);
      const userObjectId = new Types.ObjectId(userId);

      // Check if user already has a pending request
      const existingRequest = await this.joinRequestModel.findOne({
        teamId: teamObjectId,
        userId: userObjectId,
        status: 'pending',
      });

      if (existingRequest) {
        this.logger.error('Create join request error: You already have a pending join request for this team');
        throw new BadRequestException('You already have a pending join request for this team');
      }

      // Check if user is already a team member
      const team = await this.teamModel.findById(teamId);
      if (!team) {
        throw new NotFoundException('Team not found');
      }

      const isMember = team.members.some(
        (member) => member.user?.toString() === userId,
      );
      if (isMember) {
        throw new BadRequestException('You are already a member of this team');
      }

      // Create the join request with correct field names
      const joinRequest = new this.joinRequestModel({
        teamId: teamObjectId,
        userId: userObjectId,
        message,
        status: 'pending',
      });

      const savedRequest = await joinRequest.save();
      this.logger.log(`Join request created: ${savedRequest._id} for team: ${teamId} by user: ${userId}`);

      return savedRequest;
    } catch (error) {
      this.logger.error(`Create join request error: ${error.message}`, error.stack);
      // If it's a duplicate key error, provide more specific message
      if (error.code === 11000) {
        // Check if the error is about the teamId_userId index
        if (error.keyPattern && (error.keyPattern.teamId === 1 && error.keyPattern.userId === 1)) {
          throw new BadRequestException('You already have a pending join request for this team');
        }
        // Handle the case where team or user fields might be null
        if (error.keyValue && (error.keyValue.team === null || error.keyValue.user === null)) {
          throw new BadRequestException('Invalid join request data. Team and user must be specified.');
        }
      }
      throw error;
    }
  }

  async getRequestsByTeam(teamId: string): Promise<any[]> {
    this.logger.log(`Fetching join requests for team: ${teamId}`);
    
    const requests = await this.joinRequestModel
      .find({ 
        teamId: new Types.ObjectId(teamId),
        status: JoinRequestStatus.PENDING 
      })
      .populate('userId', 'name email picture skills')
      .populate('teamId', 'name') // Populate team info if needed
      .sort({ createdAt: -1 })
      .lean()
      .exec();

    this.logger.log(`Found ${requests.length} pending requests for team: ${teamId}`);
    
    // Log the raw data for debugging
    this.logger.debug(`Raw requests data: ${JSON.stringify(requests, null, 2)}`);
    
    // Transform to match frontend expectations
    return requests.map(req => {
      const user = req.userId as any;
      const team = req.teamId as any;
      const request = req as any;
      
      return {
        id: request._id.toString(),
        teamId: request.teamId.toString(),
        teamName: team?.name || 'Unknown Team',
        userId: user?._id?.toString() || user?.toString() || 'unknown',
        userName: user?.name || 'Unknown User',
        userEmail: user?.email || '',
        userPicture: user?.picture || null,
        status: request.status,
        message: request.message || null,
        createdAt: request.createdAt,
        updatedAt: request.updatedAt,
      };
    });
  }

  async handleJoinRequest(
    requestId: string,
    action: 'approve' | 'reject',
    handledBy: string,
  ): Promise<JoinRequest> {
    this.logger.log(`Handling join request: ${requestId} with action: ${action}`);

    const request = await this.joinRequestModel.findById(requestId);
    if (!request) {
      throw new NotFoundException('Join request not found');
    }

    if (request.status !== JoinRequestStatus.PENDING) {
      throw new BadRequestException('This request has already been handled');
    }

    if (action === 'approve') {
      // Add user to team
      await this.teamModel.findByIdAndUpdate(
        request.teamId,
        {
          $push: {
            members: {
              user: request.userId,
              joinedAt: new Date(),
            },
          },
        },
      );

      request.status = JoinRequestStatus.APPROVED;
      this.logger.log(`User ${request.userId} added to team ${request.teamId}`);
    } else {
      request.status = JoinRequestStatus.REJECTED;
    }

    request.handledBy = new Types.ObjectId(handledBy);
    request.handledAt = new Date();

    const updatedRequest = await request.save();
    this.logger.log(`Join request ${requestId} ${action}d successfully`);

    return updatedRequest;
  }

  // Add this method to fix the missing getDebugRequests method
  async getDebugRequests(teamId: string): Promise<any[]> {
    this.logger.log(`Debug: Fetching all join requests for team: ${teamId}`);
    
    const requests = await this.joinRequestModel
      .find({ teamId: new Types.ObjectId(teamId) })
      .populate('userId', 'name email picture skills')
      .populate('teamId', 'name')
      .sort({ createdAt: -1 })
      .lean()
      .exec();
    
    this.logger.log(`Debug: Found ${requests.length} total requests for team: ${teamId}`);
    
    return requests.map(req => {
      const user = req.userId as any;
      const team = req.teamId as any;
      const request = req as any;
      
      return {
        id: request._id.toString(),
        teamId: request.teamId.toString(),
        teamName: team?.name || 'Unknown Team',
        userId: user._id?.toString() || user.toString(),
        userName: user.name || 'Unknown User',
        userEmail: user.email || '',
        userPicture: user.picture || null,
        skills: user.skills || [],
        status: request.status,
        message: request.message || null,
        createdAt: request.createdAt,
        updatedAt: request.updatedAt,
      };
    });
  }
}