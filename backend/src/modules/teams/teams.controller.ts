// teams.controller.ts
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

  @Post('join/:teamId') // CHANGED: inviteCode → teamId
  @ApiOperation({ summary: 'Join team using team ID' })
  @ApiParam({ name: 'teamId', type: String, description: 'Team ID' }) // CHANGED
  @ApiResponse({ status: 200, description: 'Joined team successfully' })
  @ApiResponse({ status: 404, description: 'Team not found' })
  async joinTeam(
    @Param('teamId') teamId: string, // CHANGED: inviteCode → teamId
    @Request() req
  ) {
    return this.teamsService.joinTeam(teamId, req.user.userId); // CHANGED
  }

  @Get('search/my-teams')
@ApiOperation({ summary: 'Search current user teams' })
@ApiResponse({ status: 200, description: 'Search completed successfully' })
async searchUserTeams(@Query('q') query: string, @Request() req) {
  console.log('🟡 GET /teams/search/my-teams called with query:', query);
  try {
    const result = await this.teamsService.searchUserTeams(req.user.userId, query);
    console.log('🟢 GET /teams/search/my-teams success, found teams:', result.length);
    return result;
  } catch (error) {
    console.log('🔴 GET /teams/search/my-teams error:', error.message);
    throw error;
  }
}

@Get('search/browse')
@ApiOperation({ summary: 'Search all teams except current user teams' })
@ApiResponse({ status: 200, description: 'Search completed successfully' })
async searchBrowseTeams(@Query('q') query: string, @Request() req) {
  console.log('🟡 GET /teams/search/browse called with query:', query);
  try {
    const result = await this.teamsService.searchTeamsExceptUser(req.user.userId, query);
    console.log('🟢 GET /teams/search/browse success, found teams:', result.length);
    return result;
  } catch (error) {
    console.log('🔴 GET /teams/search/browse error:', error.message);
    throw error;
  }
}

@Get('search/all')
@ApiOperation({ summary: 'Search all teams' })
@ApiResponse({ status: 200, description: 'Search completed successfully' })
async searchAllTeams(@Query('q') query: string) {
  console.log('🟡 GET /teams/search/all called with query:', query);
  try {
    const result = await this.teamsService.searchAllTeams(query);
    console.log('🟢 GET /teams/search/all success, found teams:', result.length);
    return result;
  } catch (error) {
    console.log('🔴 GET /teams/search/all error:', error.message);
    throw error;
  }
}
  // Remove inviteMember and regenerateInviteCode endpoints
}