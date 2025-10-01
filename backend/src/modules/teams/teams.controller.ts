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
  ParseIntPipe,
  DefaultValuePipe,
  HttpStatus,
} from '@nestjs/common';
import { TeamsService } from './teams.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CreateTeamDto } from './dto/create-team.dto';
import { UpdateTeamDto } from './dto/update-team.dto';
import { InviteMemberDto } from './dto/invite-member.dto';
import { 
  ApiTags, 
  ApiOperation, 
  ApiResponse, 
  ApiBearerAuth, 
  ApiQuery,
  ApiParam 
} from '@nestjs/swagger';

@ApiTags('teams')
@ApiBearerAuth()
@Controller('teams')
@UseGuards(JwtAuthGuard)
export class TeamsController {
  constructor(private readonly teamsService: TeamsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new team' })
  @ApiResponse({ 
    status: HttpStatus.CREATED, 
    description: 'Team created successfully' 
  })
  @ApiResponse({ 
    status: HttpStatus.BAD_REQUEST, 
    description: 'Invalid input' 
  })
  @ApiResponse({ 
    status: HttpStatus.UNAUTHORIZED, 
    description: 'Unauthorized' 
  })
  async create(@Body() createTeamDto: CreateTeamDto, @Request() req) {
    return this.teamsService.create(createTeamDto, req.user.userId);
  }

  @Get()
  @ApiOperation({ summary: 'Get all teams with pagination and search' })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 10 })
  @ApiQuery({ name: 'search', required: false, type: String })
  @ApiResponse({ 
    status: HttpStatus.OK, 
    description: 'Teams retrieved successfully' 
  })
  async findAll(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(10), ParseIntPipe) limit: number,
    @Query('search') search?: string,
  ) {
    return this.teamsService.findAll(page, limit, search);
  }

  @Get('search')
  @ApiOperation({ summary: 'Search teams by skills and keywords' })
  @ApiQuery({ name: 'skills', required: false, type: String })
  @ApiQuery({ name: 'search', required: false, type: String })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 10 })
  @ApiResponse({ 
    status: HttpStatus.OK, 
    description: 'Teams search completed successfully' 
  })
  async searchTeams(
    @Query('skills') skills?: string,
    @Query('search') search?: string,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page?: number,
    @Query('limit', new DefaultValuePipe(10), ParseIntPipe) limit?: number,
  ) {
    const skillsArray = skills ? skills.split(',') : undefined;
    return this.teamsService.searchTeams(skillsArray, search, page, limit);
  }

  @Get('my-teams')
  @ApiOperation({ summary: 'Get current user teams' })
  @ApiResponse({ 
    status: HttpStatus.OK, 
    description: 'User teams retrieved successfully' 
  })
  async getUserTeams(@Request() req) {
    return this.teamsService.getUserTeams(req.user.userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get team by ID' })
  @ApiParam({ name: 'id', type: String, description: 'Team ID' })
  @ApiResponse({ 
    status: HttpStatus.OK, 
    description: 'Team retrieved successfully' 
  })
  @ApiResponse({ 
    status: HttpStatus.NOT_FOUND, 
    description: 'Team not found' 
  })
  async findOne(@Param('id') id: string) {
    return this.teamsService.findOne(id);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update team' })
  @ApiParam({ name: 'id', type: String, description: 'Team ID' })
  @ApiResponse({ 
    status: HttpStatus.OK, 
    description: 'Team updated successfully' 
  })
  @ApiResponse({ 
    status: HttpStatus.FORBIDDEN, 
    description: 'Forbidden' 
  })
  @ApiResponse({ 
    status: HttpStatus.NOT_FOUND, 
    description: 'Team not found' 
  })
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
  @ApiResponse({ 
    status: HttpStatus.OK, 
    description: 'Team deleted successfully' 
  })
  @ApiResponse({ 
    status: HttpStatus.FORBIDDEN, 
    description: 'Forbidden' 
  })
  @ApiResponse({ 
    status: HttpStatus.NOT_FOUND, 
    description: 'Team not found' 
  })
  async remove(@Param('id') id: string, @Request() req) {
    return this.teamsService.remove(id, req.user.userId);
  }

  @Post(':id/invite')
  @ApiOperation({ summary: 'Invite member to team' })
  @ApiParam({ name: 'id', type: String, description: 'Team ID' })
  @ApiResponse({ 
    status: HttpStatus.OK, 
    description: 'Member invited successfully' 
  })
  @ApiResponse({ 
    status: HttpStatus.FORBIDDEN, 
    description: 'Forbidden' 
  })
  @ApiResponse({ 
    status: HttpStatus.NOT_FOUND, 
    description: 'Team or user not found' 
  })
  async inviteMember(
    @Param('id') id: string, 
    @Body() inviteMemberDto: InviteMemberDto, 
    @Request() req
  ) {
    return this.teamsService.inviteMember(id, inviteMemberDto, req.user.userId);
  }

  @Post(':id/join')
  @ApiOperation({ summary: 'Request to join a team' })
  @ApiParam({ name: 'id', type: String, description: 'Team ID' })
  @ApiResponse({ 
    status: HttpStatus.OK, 
    description: 'Join request sent successfully' 
  })
  @ApiResponse({ 
    status: HttpStatus.FORBIDDEN, 
    description: 'Forbidden' 
  })
  @ApiResponse({ 
    status: HttpStatus.NOT_FOUND, 
    description: 'Team not found' 
  })
  async joinTeam(
    @Param('id') id: string, 
    @Request() req, 
    @Body() body: { message?: string }
  ) {
    return this.teamsService.joinTeam(id, req.user.userId, body.message);
  }

  @Post(':id/join-requests/:userId/respond')
  @ApiOperation({ summary: 'Respond to join request' })
  @ApiParam({ name: 'id', type: String, description: 'Team ID' })
  @ApiParam({ name: 'userId', type: String, description: 'User ID who requested to join' })
  @ApiResponse({ 
    status: HttpStatus.OK, 
    description: 'Join request responded successfully' 
  })
  @ApiResponse({ 
    status: HttpStatus.FORBIDDEN, 
    description: 'Forbidden' 
  })
  @ApiResponse({ 
    status: HttpStatus.NOT_FOUND, 
    description: 'Team or request not found' 
  })
  async respondToJoinRequest(
    @Param('id') id: string,
    @Param('userId') userId: string,
    @Request() req,
    @Body() body: { accept: boolean },
  ) {
    return this.teamsService.respondToJoinRequest(id, userId, req.user.userId, body.accept);
  }

  @Delete(':id/members/:memberId')
  @ApiOperation({ summary: 'Remove member from team' })
  @ApiParam({ name: 'id', type: String, description: 'Team ID' })
  @ApiParam({ name: 'memberId', type: String, description: 'Member ID to remove' })
  @ApiResponse({ 
    status: HttpStatus.OK, 
    description: 'Member removed successfully' 
  })
  @ApiResponse({ 
    status: HttpStatus.FORBIDDEN, 
    description: 'Forbidden' 
  })
  @ApiResponse({ 
    status: HttpStatus.NOT_FOUND, 
    description: 'Team or member not found' 
  })
    async removeMember(
      @Param('id') id: string, 
      @Param('memberId') memberId: string, 
      @Request() req
    ) {
      return this.teamsService.removeMember(id, memberId, req.user.userId);
    }
  }