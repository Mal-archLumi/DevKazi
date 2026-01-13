// admin/admin.controller.ts
import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { UserRole } from '../modules/users/schemas/user.schema';

@ApiTags('Admin')
@ApiBearerAuth()
@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
export class AdminController {
  
  @Get()
  @ApiOperation({ summary: 'Admin dashboard overview' })
  @ApiResponse({ status: 200, description: 'Returns admin dashboard data' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  async getAdminDashboard() {
    return {
      message: 'Welcome to DevKazi Admin Panel',
      endpoints: {
        users: '/admin/users',
        teams: '/admin/teams',
        projects: '/admin/projects',
        analytics: '/admin/analytics',
      },
      description: 'Administrative interface for managing DevKazi platform',
    };
  }

  @Get('health')
  @ApiOperation({ summary: 'Admin health check' })
  async healthCheck() {
    return {
      status: 'OK',
      service: 'admin',
      timestamp: new Date().toISOString(),
      message: 'Admin service is running',
    };
  }
}