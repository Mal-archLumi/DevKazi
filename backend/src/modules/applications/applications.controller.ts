import { Controller, Get, Post, Body, Param, Put, UseGuards, Req } from '@nestjs/common';
import { ApplicationsService } from './applications.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@Controller('applications')
@UseGuards(JwtAuthGuard)
export class ApplicationsController {
  constructor(private readonly applicationsService: ApplicationsService) {}

  @Post()
  async create(@Body() createApplicationDto: any, @Req() req: any) {
    const applicationData = {
      ...createApplicationDto,
      applicant: req.user.userId
    };
    return this.applicationsService.create(applicationData);
  }

  @Get('my-applications')
  async getMyApplications(@Req() req: any) {
    return this.applicationsService.findByUser(req.user.userId);
  }

  @Get('post/:postId')
  async getPostApplications(@Param('postId') postId: string) {
    return this.applicationsService.findByPost(postId);
  }

  @Put(':id/status')
  async updateStatus(@Param('id') id: string, @Body('status') status: string) {
    return this.applicationsService.updateStatus(id, status);
  }
}