// src/modules/projects/projects.controller.ts (UPDATED)
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
  Request 
} from '@nestjs/common';
import { ProjectsService } from './projects.service';
import { CreateProjectDto } from './dto/create-project.dto';
import { UpdateProjectDto } from './dto/update-project.dto';
import { PinLinkDto } from './dto/pin-link.dto';
import { AddIdeaDto } from './dto/add-idea.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@Controller('projects')
@UseGuards(JwtAuthGuard)
export class ProjectsController {
  constructor(private readonly projectsService: ProjectsService) {
    console.log('🟢 ProjectsController initialized');
  }

  @Post()
  create(@Body() createProjectDto: CreateProjectDto, @Request() req) {
    console.log('🟢 POST /api/v1/projects called');
    return this.projectsService.create(createProjectDto, req.user.userId);
  }

  @Get('team/:teamId')
  findByTeamId(@Param('teamId') teamId: string, @Request() req) {
    console.log(`🟢 GET /api/v1/projects/team/${teamId} called`);
    return this.projectsService.findByTeamId(teamId, req.user.userId);
  }

  @Get(':id')
  findOne(@Param('id') id: string, @Request() req) {
    console.log(`🟢 GET /api/v1/projects/${id} called`);
    return this.projectsService.findOne(id, req.user.userId);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() updateProjectDto: UpdateProjectDto, @Request() req) {
    console.log(`🟢 PUT /api/v1/projects/${id} called`);
    return this.projectsService.update(id, updateProjectDto, req.user.userId);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @Request() req) {
    console.log(`🟢 DELETE /api/v1/projects/${id} called`);
    return this.projectsService.remove(id, req.user.userId);
  }

  // Pin Link endpoints
  @Post(':id/pin-link')
  pinLink(@Param('id') id: string, @Body() pinLinkDto: PinLinkDto, @Request() req) {
    console.log(`🟢 POST /api/v1/projects/${id}/pin-link called`);
    return this.projectsService.pinLink(id, pinLinkDto, req.user.userId);
  }

  @Delete(':projectId/pin-link/:linkId')
  deletePinnedLink(@Param('projectId') projectId: string, @Param('linkId') linkId: string, @Request() req) {
    console.log(`🟢 DELETE /api/v1/projects/${projectId}/pin-link/${linkId} called`);
    return this.projectsService.deletePinnedLink(projectId, linkId, req.user.userId);
  }

  // Idea endpoints
  @Post(':id/ideas')
  addIdea(@Param('id') id: string, @Body() addIdeaDto: AddIdeaDto, @Request() req) {
    console.log(`🟢 POST /api/v1/projects/${id}/ideas called`);
    return this.projectsService.addIdea(id, addIdeaDto, req.user.userId);
  }

  @Put(':projectId/ideas/:ideaId/status')
  updateIdeaStatus(
    @Param('projectId') projectId: string, 
    @Param('ideaId') ideaId: string, 
    @Body('status') status: string, 
    @Request() req
  ) {
    console.log(`🟢 PUT /api/v1/projects/${projectId}/ideas/${ideaId}/status called`);
    return this.projectsService.updateIdeaStatus(projectId, ideaId, status, req.user.userId);
  }

  @Delete(':projectId/ideas/:ideaId')
  deleteIdea(@Param('projectId') projectId: string, @Param('ideaId') ideaId: string, @Request() req) {
    console.log(`🟢 DELETE /api/v1/projects/${projectId}/ideas/${ideaId} called`);
    return this.projectsService.deleteIdea(projectId, ideaId, req.user.userId);
  }

  // Progress endpoint
  @Put(':id/progress')
  updateProjectProgress(@Param('id') id: string, @Body('progress') progress: number, @Request() req) {
    console.log(`🟢 PUT /api/v1/projects/${id}/progress called`);
    return this.projectsService.updateProjectProgress(id, progress, req.user.userId);
  }

  // Timeline phase endpoint
  @Put(':projectId/timeline/:phaseId')
  updateTimelinePhase(
    @Param('projectId') projectId: string, 
    @Param('phaseId') phaseId: string, 
    @Body() updateData: any, 
    @Request() req
  ) {
    console.log(`🟢 PUT /api/v1/projects/${projectId}/timeline/${phaseId} called`);
    return this.projectsService.updateTimelinePhase(projectId, phaseId, updateData, req.user.userId);
  }
}