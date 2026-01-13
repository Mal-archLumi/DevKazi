// admin/controllers/admin-teams.controller.ts
import { Controller, Get, Param, Query, UseGuards, ParseIntPipe, DefaultValuePipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../../modules/users/schemas/user.schema';
import { AdminTeamsService } from '../services/admin-teams.service';

@ApiTags('Admin - Teams')
@ApiBearerAuth()
@Controller('admin/teams')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
export class AdminTeamsController {
  constructor(private readonly adminTeamsService: AdminTeamsService) {}

  @Get()
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  @ApiQuery({ name: 'search', required: false })
  @ApiOperation({ summary: 'Get all teams' })
  async getTeams(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number = 1,
    @Query('limit', new DefaultValuePipe(20), ParseIntPipe) limit: number = 20,
    @Query('search') search?: string,
  ) {
    return this.adminTeamsService.getTeams({ page, limit, search });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get team details' })
  async getTeamById(@Param('id') id: string) {
    return this.adminTeamsService.getTeamById(id);
  }

  @Get(':id/projects')
  @ApiOperation({ summary: 'Get team projects' })
  async getTeamProjects(@Param('id') id: string) {
    return this.adminTeamsService.getTeamProjects(id);
  }
}