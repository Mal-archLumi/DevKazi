// admin/controllers/admin-projects.controller.ts
import { 
  Controller, Get, Param, Query, Put, Body, UseGuards, 
  ParseIntPipe, DefaultValuePipe, BadRequestException 
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../../modules/users/schemas/user.schema';
import { AdminProjectsService } from '../services/admin-projects.service';

@ApiTags('Admin - Projects')
@ApiBearerAuth()
@Controller('admin/projects')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
export class AdminProjectsController {
  constructor(private readonly adminProjectsService: AdminProjectsService) {}

  @Get()
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  @ApiQuery({ name: 'search', required: false })
  @ApiQuery({ name: 'status', required: false })
  @ApiQuery({ name: 'teamId', required: false })
  @ApiQuery({ name: 'isActive', required: false })
  @ApiOperation({ summary: 'Get all projects with filtering' })
  async getProjects(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number = 1,
    @Query('limit', new DefaultValuePipe(20), ParseIntPipe) limit: number = 20,
    @Query('search') search?: string,
    @Query('status') status?: string,
    @Query('teamId') teamId?: string,
    @Query('isActive') isActive?: boolean,
  ) {
    // Ensure limit is reasonable
    if (limit > 100) limit = 100;
    
    return this.adminProjectsService.getProjects({
      page,
      limit,
      search,
      status,
      teamId,
      isActive: isActive !== undefined ? Boolean(isActive) : undefined,
    });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get project details by ID' })
  async getProjectById(@Param('id') id: string) {
    return this.adminProjectsService.getProjectById(id);
  }

  @Put(':id/status')
  @ApiOperation({ summary: 'Update project status' })
  async updateProjectStatus(
    @Param('id') id: string,
    @Body('status') status: string,
  ) {
    if (!status) {
      throw new BadRequestException('Status is required');
    }
    
    return this.adminProjectsService.updateProjectStatus(id, status);
  }

  @Put(':id/deactivate')
  @ApiOperation({ summary: 'Deactivate project' })
  async deactivateProject(@Param('id') id: string) {
    return this.adminProjectsService.deactivateProject(id);
  }

  @Get('insights/overview')
  @ApiOperation({ summary: 'Get project insights and overview' })
  async getProjectInsights() {
    return this.adminProjectsService.getProjectInsights();
  }
}