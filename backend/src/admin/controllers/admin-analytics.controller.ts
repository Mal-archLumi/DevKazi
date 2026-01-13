// admin/controllers/admin-analytics.controller.ts
import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../../modules/users/schemas/user.schema';
import { AdminAnalyticsService } from '../services/admin-analytics.service';

@ApiTags('Admin - Analytics')
@ApiBearerAuth()
@Controller('admin/analytics')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
export class AdminAnalyticsController {
  constructor(private readonly adminAnalyticsService: AdminAnalyticsService) {}

  @Get()
  @ApiOperation({ summary: 'Get comprehensive platform analytics' })
  @ApiResponse({ status: 200, description: 'Returns platform analytics' })
  async getPlatformAnalytics() {
    return this.adminAnalyticsService.getPlatformAnalytics();
  }

  @Get('basic')
  @ApiOperation({ summary: 'Get basic analytics for dashboard' })
  async getBasicAnalytics() {
    return this.adminAnalyticsService.getBasicAnalytics();
  }

  @Get('health')
  @ApiOperation({ summary: 'Analytics service health check' })
  async healthCheck() {
    return {
      status: 'OK',
      service: 'admin-analytics',
      timestamp: new Date().toISOString(),
    };
  }
}