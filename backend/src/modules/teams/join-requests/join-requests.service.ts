// teams/join-requests/join-requests.service.ts
import {
  Injectable,
  BadRequestException,
  NotFoundException,
  Logger,
  InternalServerErrorException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import {
  JoinRequest,
  JoinRequestDocument,
  JoinRequestStatus,
} from '../schemas/join-request.schema';
import { Team, TeamDocument } from '../schemas/team.schema';
import { User, UserDocument } from '../../users/schemas/user.schema';
import { TeamsService } from '../teams.service';
import { NotificationsService } from '../../notifications/notifications.service';
import { UsersService } from '../../users/users.service';

@Injectable()
export class JoinRequestsService {
  private readonly logger = new Logger(JoinRequestsService.name);

  constructor(
    @InjectModel(JoinRequest.name)
    public joinRequestModel: Model<JoinRequestDocument>,
    @InjectModel(Team.name)
    private teamModel: Model<TeamDocument>,
    @InjectModel(User.name)
    private userModel: Model<UserDocument>,
    private readonly notificationsService: NotificationsService,
    private readonly teamsService: TeamsService,
    private readonly usersService: UsersService,
  ) {}

  findOne(requestId: string) {
    return this.joinRequestModel.findById(requestId).exec();
  }

  async createJoinRequest(teamId: string, userId: string, message?: string) {
    try {
      // Validate inputs
      if (!Types.ObjectId.isValid(teamId)) {
        throw new BadRequestException('Invalid team ID');
      }
      if (!Types.ObjectId.isValid(userId)) {
        throw new BadRequestException('Invalid user ID');
      }

      // Check if user is already a member of the team
      const team = await this.teamModel.findById(teamId);
      if (!team) {
        throw new NotFoundException('Team not found');
      }

      const isAlreadyMember = team.members.some(
        (member) => member.user.toString() === userId,
      );

      if (isAlreadyMember) {
        throw new BadRequestException(
          'You are already a member of this team',
        );
      }

      // Check for existing pending request - FIXED: use teamId and userId
      const existingRequest = await this.joinRequestModel.findOne({
        teamId: new Types.ObjectId(teamId),
        userId: new Types.ObjectId(userId),
        status: JoinRequestStatus.PENDING,
      });

      if (existingRequest) {
        throw new BadRequestException(
          'You already have a pending join request for this team',
        );
      }

      // Get team with owner populated
      const teamWithOwner = await this.teamModel
        .findById(teamId)
        .populate('owner', 'name email')
        .exec();

      if (!teamWithOwner) {
        throw new NotFoundException('Team not found');
      }

      // Get requester details
      const requester = await this.userModel.findById(userId);
      if (!requester) {
        throw new NotFoundException('User not found');
      }

      // Get team owner ID - safely extract from populated owner
      const owner = teamWithOwner.owner as any;
      const teamOwnerId =
        owner && (owner._id ? owner._id.toString() : owner.toString());

      // Get team name
      const teamName = teamWithOwner.name || 'Team';

      // Get requester name
      const requesterName = requester.name || 'Someone';

      // Create the join request - FIXED: use teamId and userId
      const joinRequest = new this.joinRequestModel({
        teamId: new Types.ObjectId(teamId),
        userId: new Types.ObjectId(userId),
        message,
        status: JoinRequestStatus.PENDING,
      });

      const savedRequest = await joinRequest.save();

      this.logger.log(
        `Join request created: ${savedRequest._id} for team: ${teamId} by user: ${userId}`,
      );

      // Create notification - with proper error handling
      try {
        await this.notificationsService.createJoinRequestNotification(
          teamId,
          teamOwnerId,
          userId,
          requesterName,
          teamName,
        );
        this.logger.log(
          `✅ Join request notification created for team owner ${teamOwnerId}`,
        );
      } catch (notificationError) {
        this.logger.error(
          `Failed to create notification, but join request was saved: ${notificationError.message}`,
        );
        // Don't throw - the join request was successfully created
      }

      return savedRequest;
    } catch (error) {
      this.logger.error(`Create join request error: ${error.message}`);
      if (
        error instanceof NotFoundException ||
        error instanceof BadRequestException
      ) {
        throw error;
      }
      throw new InternalServerErrorException('Failed to create join request');
    }
  }

  async getRequestsByTeam(teamId: string): Promise<any[]> {
    this.logger.log(`Fetching join requests for team: ${teamId}`);

    const requests = (await this.joinRequestModel
      .find({
        teamId: new Types.ObjectId(teamId), // FIXED: use teamId
        status: JoinRequestStatus.PENDING,
      })
      .populate('userId', 'name email picture skills') // FIXED: use userId
      .populate('teamId', 'name') // FIXED: use teamId
      .sort({ createdAt: -1 })
      .lean()
      .exec()) as any[];

    this.logger.log(
      `Found ${requests.length} pending requests for team: ${teamId}`,
    );

    // Transform to match frontend expectations
    return requests.map((req) => {
      const user = req.userId as any; // FIXED: use userId
      const team = req.teamId as any; // FIXED: use teamId
      const request = req as any;

      return {
        id: request._id.toString(),
        teamId: request.teamId?.toString() || teamId,
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
  ): Promise<JoinRequestDocument> {
    this.logger.log(
      `Handling join request: ${requestId} with action: ${action}`,
    );

    const request = (await this.joinRequestModel
      .findById(requestId)
      .exec()) as JoinRequestDocument | null;

    if (!request) {
      throw new NotFoundException('Join request not found');
    }

    if (request.status !== JoinRequestStatus.PENDING) {
      throw new BadRequestException('This request has already been handled');
    }

    // Fetch team for name - FIXED: use teamId
    const teamId = request.teamId;
    const userId = request.userId;

    const team = await this.teamModel.findById(teamId).exec();
    if (!team) {
      throw new NotFoundException('Team not found');
    }

    if (action === 'approve') {
      // Add user to team
      await this.teamModel.findByIdAndUpdate(teamId, {
        $push: {
          members: {
            user: userId,
            joinedAt: new Date(),
          },
        },
      });

      request.status = JoinRequestStatus.APPROVED;
      this.logger.log(`User ${String(userId)} added to team ${String(teamId)}`);

      // Notify requester
      await this.notificationsService.createJoinApprovedNotification(
        String(teamId),
        String(userId),
        team.name,
        handledBy,
      );
    } else {
      request.status = JoinRequestStatus.REJECTED;

      // Notify requester
      await this.notificationsService.createJoinRejectedNotification(
        String(teamId),
        String(userId),
        team.name,
        handledBy,
      );
    }

    request.handledBy = new Types.ObjectId(handledBy);
    request.handledAt = new Date();

    const updatedRequest = await request.save();

    this.logger.log(`Join request ${requestId} ${action}d successfully`);

    return updatedRequest;
  }

  async getDebugRequests(teamId: string): Promise<any[]> {
    this.logger.log(`Debug: Fetching all join requests for team: ${teamId}`);

    const requests = (await this.joinRequestModel
      .find({ teamId: new Types.ObjectId(teamId) }) // FIXED: use teamId
      .populate('userId', 'name email picture skills') // FIXED: use userId
      .populate('teamId', 'name') // FIXED: use teamId
      .sort({ createdAt: -1 })
      .lean()
      .exec()) as any[];

    this.logger.log(
      `Debug: Found ${requests.length} total requests for team: ${teamId}`,
    );

    return requests.map((req) => {
      const user = req.userId as any; // FIXED: use userId
      const team = req.teamId as any; // FIXED: use teamId
      const request = req as any;

      return {
        id: request._id.toString(),
        teamId: request.teamId?.toString() || teamId,
        teamName: team?.name || 'Unknown Team',
        userId: user?._id?.toString() || user?.toString() || 'unknown',
        userName: user?.name || 'Unknown User',
        userEmail: user?.email || '',
        userPicture: user?.picture || null,
        skills: user?.skills || [],
        status: request.status,
        message: request.message || null,
        createdAt: request.createdAt,
        updatedAt: request.updatedAt,
      };
    });
  }
}