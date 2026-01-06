// join-requests.controller.ts
import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  Param,
  Request,
  UseGuards,
  ForbiddenException,
  Logger,
  Delete,
} from '@nestjs/common';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { JoinRequestsService } from './join-requests.service';
import { TeamsService } from '../teams.service';
import { ApiOperation, ApiTags } from '@nestjs/swagger';

@ApiTags('join-requests')
@Controller('join-requests')
@UseGuards(JwtAuthGuard)
export class JoinRequestsController {
  private readonly logger = new Logger(JoinRequestsController.name);

  constructor(
    private readonly joinRequestsService: JoinRequestsService,
    private readonly teamsService: TeamsService,
  ) {}

  @Put('approve/:requestId')
  @ApiOperation({ summary: 'Approve join request' })
  async approveJoinRequest(
    @Request() req,
    @Param('requestId') requestId: string,
  ) {
    const userId = req.user.userId || req.user.sub || req.user._id;
    
    this.logger.log(`🟡 Approving join request: ${requestId} by user: ${userId}`);

    const request = await this.joinRequestsService.joinRequestModel.findById(requestId);
    if (!request) {
      throw new ForbiddenException('Request not found');
    }

    const team = await this.teamsService.findOne(request.teamId.toString());
    
    // ✅ Extract owner ID properly (handles both populated and non-populated)
    const ownerId = (team.owner as any)?._id?.toString() || team.owner?.toString();
    
    if (ownerId !== userId) {
      throw new ForbiddenException('Only team creator can approve join requests');
    }

    return this.joinRequestsService.handleJoinRequest(
      requestId,
      'approve',
      userId,
    );
  }

  @Put('reject/:requestId')
  @ApiOperation({ summary: 'Reject join request' })
  async rejectJoinRequest(
    @Request() req,
    @Param('requestId') requestId: string,
  ) {
    const userId = req.user.userId || req.user.sub || req.user._id;
    
    this.logger.log(`🟡 Rejecting join request: ${requestId} by user: ${userId}`);

    const request = await this.joinRequestsService.joinRequestModel.findById(requestId);
    if (!request) {
      throw new ForbiddenException('Request not found');
    }

    const team = await this.teamsService.findOne(request.teamId.toString());
    
    // ✅ Extract owner ID properly (handles both populated and non-populated)
    const ownerId = (team.owner as any)?._id?.toString() || team.owner?.toString();
    
    if (ownerId !== userId) {
      throw new ForbiddenException('Only team creator can reject join requests');
    }

    return this.joinRequestsService.handleJoinRequest(
      requestId,
      'reject',
      userId,
    );
  }

  @Post()
  @ApiOperation({ summary: 'Create join request' })
  async createJoinRequest(
    @Request() req,
    @Body() body: { teamId: string; message?: string },
  ) {
    const userId = req.user.userId || req.user.sub || req.user._id;
    return this.joinRequestsService.createJoinRequest(
      body.teamId,
      userId,
      body.message,
    );
  }

  @Get('my-requests')
  @ApiOperation({ summary: 'Get my join requests' })
  async getMyRequests(@Request() req) {
    const userId = req.user.userId || req.user.sub || req.user._id;
    return this.joinRequestsService.getRequestsByTeam(userId);
  }

  @Get('team/:teamId')
  @ApiOperation({ summary: 'Get team join requests' })
  async getTeamJoinRequests(@Request() req, @Param('teamId') teamId: string) {
    const userId = req.user.userId || req.user.sub || req.user._id;

    this.logger.log(`🟡 Getting join requests for team: ${teamId} by user: ${userId}`);

    const team = await this.teamsService.findOne(teamId);
    if (!team) {
      throw new ForbiddenException('Team not found');
    }

    // ✅ FIX: Extract owner ID from populated or non-populated owner field
    const ownerId = (team.owner as any)?._id?.toString() || team.owner?.toString();
    
    this.logger.log(`🟡 Team owner ID: ${ownerId}, Current user ID: ${userId}`);
    
    if (ownerId !== userId) {
      throw new ForbiddenException('Only team creator can view join requests');
    }

    return this.joinRequestsService.getRequestsByTeam(teamId);
  }

  @Delete(':requestId')
  @ApiOperation({ summary: 'Cancel join request' })
  async cancelJoinRequest(
    @Request() req,
    @Param('requestId') requestId: string,
  ) {
    const userId = req.user.userId || req.user.sub || req.user._id;
    
    this.logger.log(`🟡 Cancelling join request: ${requestId} by user: ${userId}`);

    const request = await this.joinRequestsService.joinRequestModel.findById(requestId);
    if (!request) {
      throw new ForbiddenException('Request not found');
    }

    const requestUserId = (request as any).userId.toString();
    if (requestUserId !== userId) {
      throw new ForbiddenException('You can only cancel your own join requests');
    }

    if ((request as any).status !== 'pending') {
      throw new ForbiddenException('Only pending requests can be cancelled');
    }

    await this.joinRequestsService.joinRequestModel.findByIdAndDelete(requestId);
    
    return { message: 'Join request cancelled successfully' };
  }

  @Get(':requestId')
  @ApiOperation({ summary: 'Get specific join request' })
  async getJoinRequest(
    @Request() req,
    @Param('requestId') requestId: string,
  ) {
    const request = await this.joinRequestsService.joinRequestModel.findById(requestId);
    if (!request) {
      throw new ForbiddenException('Request not found');
    }

    const userId = req.user.userId || req.user.sub || req.user._id;
    const team = await this.teamsService.findOne((request as any).teamId.toString());
    
    // ✅ Extract owner ID properly
    const ownerId = (team.owner as any)?._id?.toString() || team.owner?.toString();
    const isOwner = ownerId === userId;
    const isRequester = (request as any).userId.toString() === userId;
    
    if (!isOwner && !isRequester) {
      throw new ForbiddenException('You do not have permission to view this request');
    }

    return request;
  }
}