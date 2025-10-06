import { 
  Controller, 
  Get, 
  Post, 
  Put, 
  Body, 
  Param, 
  UseGuards, 
  Req,
  HttpStatus,
  HttpCode
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { ApplicationsService } from './applications.service';
import { CreateApplicationDto } from './dto/create-application.dto';
import { ApplicationStatusDto } from './dto/application-status.dto';
import { ApplicationResponseDto } from './dto/application-response.dto';

@ApiTags('applications')
@Controller('applications')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ApplicationsController {
  constructor(private readonly applicationsService: ApplicationsService) {}

  @Post()
  @ApiOperation({ summary: 'Apply for an internship post' })
  @ApiResponse({ status: 201, description: 'Application submitted successfully', type: ApplicationResponseDto })
  @ApiResponse({ status: 400, description: 'Invalid application data' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async create(
    @Body() createApplicationDto: CreateApplicationDto, 
    @Req() req: any
  ): Promise<ApplicationResponseDto> {
    return this.applicationsService.create(createApplicationDto, req.user.userId);
  }

  @Get('my-applications')
  @ApiOperation({ summary: 'Get all applications by the current user' })
  @ApiResponse({ status: 200, description: 'Applications retrieved successfully' })
  async getMyApplications(@Req() req: any): Promise<ApplicationResponseDto[]> {
    return this.applicationsService.getUserApplications(req.user.userId);
  }

  @Get('team/:teamId')
  @ApiOperation({ summary: 'Get all applications for a team' })
  @ApiResponse({ status: 200, description: 'Team applications retrieved successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not team admin' })
  async getTeamApplications(
    @Param('teamId') teamId: string, 
    @Req() req: any
  ): Promise<ApplicationResponseDto[]> {
    return this.applicationsService.getTeamApplications(teamId, req.user.userId);
  }

  @Put(':id/status')
  @ApiOperation({ summary: 'Update application status' })
  @ApiResponse({ status: 200, description: 'Application status updated successfully', type: ApplicationResponseDto })
  @ApiResponse({ status: 403, description: 'Forbidden - Not team admin' })
  async updateStatus(
    @Param('id') id: string,
    @Body() statusDto: ApplicationStatusDto,
    @Req() req: any
  ): Promise<ApplicationResponseDto> {
    return this.applicationsService.updateStatus(id, statusDto, req.user.userId);
  }

  @Put(':id/withdraw')
  @ApiOperation({ summary: 'Withdraw an application' })
  @ApiResponse({ status: 200, description: 'Application withdrawn successfully', type: ApplicationResponseDto })
  @ApiResponse({ status: 403, description: 'Forbidden - Not application owner' })
  async withdrawApplication(
    @Param('id') id: string,
    @Req() req: any
  ): Promise<ApplicationResponseDto> {
    return this.applicationsService.withdrawApplication(id, req.user.userId);
  }

  @Get('team/:teamId/stats')
  @ApiOperation({ summary: 'Get application statistics for a team' })
  @ApiResponse({ status: 200, description: 'Statistics retrieved successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not team admin' })
  async getApplicationStats(
    @Param('teamId') teamId: string, 
    @Req() req: any
  ): Promise<{ [key: string]: number }> {
    return this.applicationsService.getApplicationStats(teamId, req.user.userId);
  }

  @Get('team/:teamId/analytics')
  @ApiOperation({ summary: 'Get detailed application analytics for a team' })
  @ApiResponse({ status: 200, description: 'Analytics retrieved successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not team admin' })
  async getApplicationAnalytics(
    @Param('teamId') teamId: string, 
    @Req() req: any
  ): Promise<any> {
    return this.applicationsService.getApplicationAnalytics(teamId, req.user.userId);
  }
}