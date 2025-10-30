import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { TeamsService } from './teams.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { CreateTeamDto } from './dto/create-team.dto';
import { UpdateTeamDto } from './dto/update-team.dto';
import { InviteMemberDto } from './dto/invite-member.dto';
import { 
  ApiTags, 
  ApiOperation, 
  ApiResponse, 
  ApiBearerAuth,
  ApiParam 
} from '@nestjs/swagger';

@ApiTags('teams')
@ApiBearerAuth()
@Controller('teams')
@UseGuards(JwtAuthGuard)
export class TeamsController {
  constructor(private readonly teamsService: TeamsService) {}

 @Get()
@ApiOperation({ summary: 'Get all teams' })
@ApiResponse({ status: 200, description: 'All teams retrieved successfully' })
async findAll() {
  console.log('🟡 GET /teams called');
  try {
    const result = await this.teamsService.findAll();
    console.log('🟢 GET /teams success, found teams:', result.length);
    return result;
  } catch (error) {
    console.log('🔴 GET /teams error:', error.message);
    throw error;
  }
}


  @Post()
  @ApiOperation({ summary: 'Create a new team' })
  @ApiResponse({ status: 201, description: 'Team created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  async create(@Body() createTeamDto: CreateTeamDto, @Request() req) {
    return this.teamsService.create(createTeamDto, req.user.userId);
  }

  @Get('my-teams')
  @ApiOperation({ summary: 'Get current user teams' })
  @ApiResponse({ status: 200, description: 'User teams retrieved successfully' })
  async getUserTeams(@Request() req) {
    return this.teamsService.getUserTeams(req.user.userId);
  }

  @Get('browse/all')
@ApiOperation({ summary: 'Get all teams except current user teams' })
@ApiResponse({ status: 200, description: 'Teams retrieved successfully' })
async getAllTeamsExceptUser(@Request() req) {
  console.log('🟡 GET /teams/browse/all called for user:', req.user.userId);
  try {
    const result = await this.teamsService.getAllTeamsExceptUser(req.user.userId);
    console.log('🟢 GET /teams/browse/all success, found teams:', result.length);
    return result;
  } catch (error) {
    console.log('🔴 GET /teams/browse/all error:', error.message);
    throw error;
  }
}

  @Get(':id')
  @ApiOperation({ summary: 'Get team by ID' })
  @ApiParam({ name: 'id', type: String, description: 'Team ID' })
  @ApiResponse({ status: 200, description: 'Team retrieved successfully' })
  @ApiResponse({ status: 404, description: 'Team not found' })
  async findOne(@Param('id') id: string) {
    return this.teamsService.findOne(id);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update team' })
  @ApiParam({ name: 'id', type: String, description: 'Team ID' })
  @ApiResponse({ status: 200, description: 'Team updated successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Team not found' })
  async update(
    @Param('id') id: string, 
    @Body() updateTeamDto: UpdateTeamDto, 
    @Request() req
  ) {
    return this.teamsService.update(id, updateTeamDto, req.user.userId);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete team' })
  @ApiParam({ name: 'id', type: String, description: 'Team ID' })
  @ApiResponse({ status: 200, description: 'Team deleted successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Team not found' })
  async remove(@Param('id') id: string, @Request() req) {
    return this.teamsService.remove(id, req.user.userId);
  }

  @Post(':id/invite')
  @ApiOperation({ summary: 'Invite member to team via email' })
  @ApiParam({ name: 'id', type: String, description: 'Team ID' })
  @ApiResponse({ status: 200, description: 'Member invited successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Team not found' })
  async inviteMember(
    @Param('id') id: string, 
    @Body() inviteMemberDto: InviteMemberDto, 
    @Request() req
  ) {
    return this.teamsService.inviteMember(id, inviteMemberDto, req.user.userId);
  }

  @Post('join/:inviteCode')
  @ApiOperation({ summary: 'Join team using invite code' })
  @ApiParam({ name: 'inviteCode', type: String, description: 'Team invite code' })
  @ApiResponse({ status: 200, description: 'Joined team successfully' })
  @ApiResponse({ status: 404, description: 'Team not found' })
  async joinTeam(
    @Param('inviteCode') inviteCode: string, 
    @Request() req
  ) {
    return this.teamsService.joinTeam(inviteCode, req.user.userId);
  }

  @Delete(':id/members/:memberId')
  @ApiOperation({ summary: 'Remove member from team' })
  @ApiParam({ name: 'id', type: String, description: 'Team ID' })
  @ApiParam({ name: 'memberId', type: String, description: 'Member ID to remove' })
  @ApiResponse({ status: 200, description: 'Member removed successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Team or member not found' })
  async removeMember(
    @Param('id') id: string, 
    @Param('memberId') memberId: string, 
    @Request() req
  ) {
    return this.teamsService.removeMember(id, memberId, req.user.userId);
  }

  @Post(':id/regenerate-invite')
  @ApiOperation({ summary: 'Regenerate team invite code' })
  @ApiParam({ name: 'id', type: String, description: 'Team ID' })
  @ApiResponse({ status: 200, description: 'Invite code regenerated' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Team not found' })
  async regenerateInviteCode(@Param('id') id: string, @Request() req) {
    return this.teamsService.regenerateInviteCode(id, req.user.userId);
  }
}