// src/modules/projects/projects.service.ts (COMPLETE FIXED VERSION)
import { 
  Injectable, 
  NotFoundException, 
  ForbiddenException, 
  BadRequestException,
  InternalServerErrorException,
  Logger 
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Project } from './schemas/project.schema';
import { HydratedDocument } from 'mongoose';

type ProjectDocument = HydratedDocument<Project>;
import { CreateProjectDto } from './dto/create-project.dto';
import { UpdateProjectDto } from './dto/update-project.dto';
import { PinLinkDto } from './dto/pin-link.dto';
import { AddIdeaDto } from './dto/add-idea.dto';
import { Team, TeamDocument } from '../teams/schemas/team.schema';
import { NotificationsService } from '../notifications/notifications.service'; // Assuming this path

@Injectable()
export class ProjectsService {
  private readonly logger = new Logger(ProjectsService.name);

  constructor(
    @InjectModel(Project.name) private projectModel: Model<ProjectDocument>,
    @InjectModel(Team.name) private teamModel: Model<TeamDocument>, 
    private readonly notificationsService: NotificationsService,
  ) {}

  async create(createProjectDto: CreateProjectDto, userId: string): Promise<Project> {
    try {
      console.log('🟡 Creating project with DTO:', JSON.stringify(createProjectDto, null, 2));

      // Handle assignments - properly handle all fields
      const validAssignments = (createProjectDto.assignments || []).map(assignment => {
        const assignmentData: any = {
          role: assignment.role,
          tasks: assignment.tasks || '',
        };

        // Handle userId field
        if (assignment.userId && assignment.userId.trim() !== '' && Types.ObjectId.isValid(assignment.userId)) {
          assignmentData.user = new Types.ObjectId(assignment.userId);
        }

        // Handle assignedTo field
        if (assignment.assignedTo && assignment.assignedTo.trim() !== '') {
          assignmentData.assignedTo = assignment.assignedTo.trim();
        }

        return assignmentData;
      });

      // Handle timeline - convert dates properly
      const validTimeline = (createProjectDto.timeline || []).map(phase => {
        if (!phase.phase || phase.phase.trim() === '') {
          throw new BadRequestException('Phase name cannot be empty');
        }

        const timelinePhase: any = {
          phase: phase.phase,
          description: phase.description || '',
          status: phase.status || 'planned'
        };

        // Convert string dates to Date objects if they exist
        if (phase.startDate) {
          timelinePhase.startDate = new Date(phase.startDate);
        }
        if (phase.endDate) {
          timelinePhase.endDate = new Date(phase.endDate);
        }

        return timelinePhase;
      });

      const projectData = {
        name: createProjectDto.name.trim(),
        description: createProjectDto.description?.trim() || '',
        teamId: new Types.ObjectId(createProjectDto.teamId),
        createdBy: new Types.ObjectId(userId),
        assignments: validAssignments,
        timeline: validTimeline,
        lastUpdated: new Date(),
        isActive: true,
        status: 'active',
        progress: 0
      };

      console.log('🟡 Final project data:', JSON.stringify(projectData, null, 2));

      const project = new this.projectModel(projectData);
      const savedProject = await project.save();
      
      // Populate the saved project
      const populatedProject = await this.projectModel
        .findById(savedProject._id)
        .populate('createdBy', 'name email')
        .populate('assignments.user', 'name email avatar')
        .exec();

      console.log('✅ Project created successfully:', populatedProject._id);

      // Get team member IDs
      const teamMemberIds = await this.getTeamMemberIds(createProjectDto.teamId);

      // Create notification
      await this.notificationsService.createProjectCreatedNotification(
        savedProject._id.toString(),
        savedProject.name,
        createProjectDto.teamId,
        teamMemberIds,
        userId,
      );

      return populatedProject;
    } catch (error) {
      console.error('❌ Create project error:', error);
      if (error instanceof BadRequestException) {
        throw error;
      }
      throw new InternalServerErrorException('Failed to create project: ' + error.message);
    }
  }

  async findByTeamId(teamId: string, userId: string): Promise<Project[]> {
    try {
      if (!Types.ObjectId.isValid(teamId)) {
        throw new BadRequestException('Invalid team ID');
      }

      const projects = await this.projectModel
        .find({ 
          teamId: new Types.ObjectId(teamId),
          isActive: true 
        })
        .populate('createdBy', 'name email')
        .populate('assignments.user', 'name email avatar')
        .populate('pinnedLinks.pinnedBy', 'name email')
        .populate('ideas.createdBy', 'name email')
        .sort({ lastUpdated: -1 })
        .exec();

      return projects;
    } catch (error) {
      this.logger.error(`Failed to fetch projects for team ${teamId}: ${error.message}`);
      if (error instanceof BadRequestException) throw error;
      throw new InternalServerErrorException('Failed to fetch projects');
    }
  }

  async findOne(id: string, userId: string): Promise<Project> {
  try {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('Invalid project ID');
    }

    const project = await this.projectModel
      .findById(id)
      .populate('createdBy', '_id name email')  // Added _id to ensure we can compare properly
      .populate('assignments.user', 'name email avatar')
      .populate('pinnedLinks.pinnedBy', 'name email')
      .populate('ideas.createdBy', 'name email')
      .exec();

    if (!project) {
      throw new NotFoundException('Project not found');
    }

    // Verify user has access to this project
    const isTeamMember = await this.verifyTeamMembership(project.teamId.toString(), userId);
    if (!isTeamMember) {
      throw new ForbiddenException('Access denied to this project');
    }

    return project;
  } catch (error) {
    this.logger.error(`Failed to fetch project ${id}: ${error.message}`);
    if (error instanceof NotFoundException || error instanceof ForbiddenException || error instanceof BadRequestException) {
      throw error;
    }
    throw new InternalServerErrorException('Failed to fetch project');
  }
}

  async update(id: string, updateProjectDto: UpdateProjectDto, userId: string): Promise<Project> {
    try {
      console.log(`🟡 Updating project ${id} with data:`, JSON.stringify(updateProjectDto, null, 2));
      
      if (!Types.ObjectId.isValid(id)) {
        throw new BadRequestException('Invalid project ID');
      }

      const project = await this.projectModel.findById(id);
      if (!project) {
        throw new NotFoundException('Project not found');
      }

      // Verify user has access
      const isTeamMember = await this.verifyTeamMembership(project.teamId.toString(), userId);
      if (!isTeamMember) {
        throw new ForbiddenException('Access denied to this project');
      }

      // Prepare update data
      const updatedData: any = {
        lastUpdated: new Date()
      };

      // Update name if provided
      if (updateProjectDto.name !== undefined) {
        updatedData.name = updateProjectDto.name.trim();
      }

      // Update description if provided
      if (updateProjectDto.description !== undefined) {
        updatedData.description = updateProjectDto.description.trim();
      }

      // Handle assignments if provided
      if (updateProjectDto.assignments) {
        updatedData.assignments = updateProjectDto.assignments.map(assignment => {
          const assignmentData: any = {
            role: assignment.role,
            tasks: assignment.tasks || '',
          };

          // Handle userId field
          if (assignment.userId && assignment.userId.trim() !== '' && Types.ObjectId.isValid(assignment.userId)) {
            assignmentData.user = new Types.ObjectId(assignment.userId);
          }

          // Handle assignedTo field
          if (assignment.assignedTo && assignment.assignedTo.trim() !== '') {
            assignmentData.assignedTo = assignment.assignedTo.trim();
          }

          return assignmentData;
        });
      }

      // Handle timeline if provided
      if (updateProjectDto.timeline) {
        updatedData.timeline = updateProjectDto.timeline.map(phase => {
          const timelinePhase: any = {
            phase: phase.phase,
            description: phase.description || '',
            status: phase.status || 'planned'
          };

          if (phase.startDate) {
            timelinePhase.startDate = new Date(phase.startDate);
          }
          if (phase.endDate) {
            timelinePhase.endDate = new Date(phase.endDate);
          }

          return timelinePhase;
        });
      }

      console.log('🟡 Final update data:', JSON.stringify(updatedData, null, 2));

      const updatedProject = await this.projectModel
        .findByIdAndUpdate(id, { $set: updatedData }, { new: true, runValidators: true })
        .populate('createdBy', 'name email')
        .populate('assignments.user', 'name email avatar')
        .populate('pinnedLinks.pinnedBy', 'name email')
        .populate('ideas.createdBy', 'name email')
        .exec();

      if (!updatedProject) {
        throw new NotFoundException('Project not found after update');
      }

      this.logger.log(`Project updated: ${id} by user: ${userId}`);
      return updatedProject;
    } catch (error) {
      this.logger.error(`Failed to update project ${id}: ${error.message}`);
      console.error('❌ Update project error details:', error);
      
      if (error instanceof NotFoundException || error instanceof ForbiddenException || error instanceof BadRequestException) {
        throw error;
      }
      throw new InternalServerErrorException('Failed to update project: ' + error.message);
    }
  }

  async pinLink(projectId: string, pinLinkDto: PinLinkDto, userId: string): Promise<Project> {
    try {
      const project = await this.findOne(projectId, userId);
      
      const newLink = {
        title: pinLinkDto.title,
        url: pinLinkDto.url,
        pinnedBy: new Types.ObjectId(userId),
        pinnedAt: new Date()
      };

      const updatedProject = await this.projectModel
        .findByIdAndUpdate(
          projectId,
          { 
            $push: { pinnedLinks: newLink },
            lastUpdated: new Date()
          },
          { new: true }
        )
        .populate('pinnedLinks.pinnedBy', 'name email')
        .populate('createdBy', 'name email')
        .populate('assignments.user', 'name email avatar')
        .exec();

      return updatedProject;
    } catch (error) {
      this.logger.error(`Failed to pin link to project ${projectId}: ${error.message}`);
      throw error;
    }
  }

  async addIdea(projectId: string, addIdeaDto: AddIdeaDto, userId: string): Promise<Project> {
    try {
      const project = await this.findOne(projectId, userId);
      
      const newIdea = {
        title: addIdeaDto.title,
        description: addIdeaDto.description,
        createdBy: new Types.ObjectId(userId),
        createdAt: new Date(),
        status: 'pending'
      };

      const updatedProject = await this.projectModel
        .findByIdAndUpdate(
          projectId,
          { 
            $push: { ideas: newIdea },
            lastUpdated: new Date()
          },
          { new: true }
        )
        .populate('ideas.createdBy', 'name email')
        .populate('createdBy', 'name email')
        .populate('assignments.user', 'name email avatar')
        .exec();

      return updatedProject;
    } catch (error) {
      this.logger.error(`Failed to add idea to project ${projectId}: ${error.message}`);
      throw error;
    }
  }

  async remove(id: string, userId: string): Promise<void> {
  try {
    const project = await this.projectModel.findById(id);
    if (!project) {
      throw new NotFoundException('Project not found');
    }

    // Get team to check ownership
    const team = await this.teamModel.findById(project.teamId); // Use injected teamModel
    
    if (!team) {
      throw new NotFoundException('Team not found for this project');
    }
    
    // Allow deletion if:
    // 1. User is the project creator OR
    // 2. User is the team owner
    const isProjectCreator = project.createdBy.toString() === userId;
    const isTeamOwner = team.owner.toString() === userId;
    
    if (!isProjectCreator && !isTeamOwner) {
      throw new ForbiddenException('Only project creator or team owner can delete the project');
    }

    // Soft delete by marking as inactive
    await this.projectModel.findByIdAndUpdate(id, { 
      isActive: false,
      deletedAt: new Date(),
      deletedBy: new Types.ObjectId(userId)
    });
    
    this.logger.log(`Project soft-deleted: ${id} by user: ${userId}`);
  } catch (error) {
    this.logger.error(`Failed to delete project ${id}: ${error.message}`);
    if (error instanceof NotFoundException || error instanceof ForbiddenException) {
      throw error;
    }
    throw new InternalServerErrorException('Failed to delete project');
  }
}
  private async getTeamForProject(teamId: string): Promise<any> {
  // This method should fetch the team to check ownership
  // Since you have TeamsService, you should inject it into ProjectsService
  // For now, you can import and use it, but better to inject it
  
  // If you can't inject TeamsService directly, you can query the team model
  // For now, let's assume you'll inject TeamsService later
  throw new Error('Implement getTeamForProject method');
}
  private async isUserTeamOwner(teamId: string, userId: string): Promise<boolean> {
  // This method checks if the user is the owner of the team
  // You need to implement this based on your team structure
  // For now, you can either:
  // 1. Inject TeamsService and call verifyTeamMembership or similar
  // 2. Directly query the team model
  
  try {
    // If you can access the teamModel directly (same database):
    const team = await this.teamModel?.findById(teamId); // Note: you need to inject teamModel
    
    if (team) {
      return team.owner.toString() === userId;
    }
    
    return false;
  } catch (error) {
    this.logger.error(`Failed to check team ownership: ${error.message}`);
    return false;
  }
}


  async deletePinnedLink(projectId: string, linkId: string, userId: string): Promise<Project> {
    try {
      const project = await this.findOne(projectId, userId);
      
      const updatedProject = await this.projectModel
        .findByIdAndUpdate(
          projectId,
          { 
            $pull: { pinnedLinks: { _id: new Types.ObjectId(linkId) } },
            lastUpdated: new Date()
          },
          { new: true }
        )
        .populate('pinnedLinks.pinnedBy', 'name email')
        .populate('createdBy', 'name email')
        .populate('assignments.user', 'name email avatar')
        .exec();

      return updatedProject;
    } catch (error) {
      this.logger.error(`Failed to delete pinned link ${linkId} from project ${projectId}: ${error.message}`);
      throw error;
    }
  }

  async updateIdeaStatus(projectId: string, ideaId: string, status: string, userId: string): Promise<Project> {
    try {
      const project = await this.findOne(projectId, userId);
      
      const updatedProject = await this.projectModel
        .findByIdAndUpdate(
          projectId,
          { 
            $set: { 'ideas.$[idea].status': status },
            lastUpdated: new Date()
          },
          { 
            new: true,
            arrayFilters: [{ 'idea._id': new Types.ObjectId(ideaId) }]
          }
        )
        .populate('ideas.createdBy', 'name email')
        .populate('createdBy', 'name email')
        .populate('assignments.user', 'name email avatar')
        .exec();

      return updatedProject;
    } catch (error) {
      this.logger.error(`Failed to update idea status ${ideaId} in project ${projectId}: ${error.message}`);
      throw error;
    }
  }

  async deleteIdea(projectId: string, ideaId: string, userId: string): Promise<Project> {
    try {
      const project = await this.findOne(projectId, userId);
      
      const updatedProject = await this.projectModel
        .findByIdAndUpdate(
          projectId,
          { 
            $pull: { ideas: { _id: new Types.ObjectId(ideaId) } },
            lastUpdated: new Date()
          },
          { new: true }
        )
        .populate('ideas.createdBy', 'name email')
        .populate('createdBy', 'name email')
        .populate('assignments.user', 'name email avatar')
        .exec();

      return updatedProject;
    } catch (error) {
      this.logger.error(`Failed to delete idea ${ideaId} from project ${projectId}: ${error.message}`);
      throw error;
    }
  }

  async updateProjectProgress(projectId: string, progress: number, userId: string): Promise<Project> {
    try {
      const project = await this.findOne(projectId, userId);
      
      const updatedProject = await this.projectModel
        .findByIdAndUpdate(
          projectId,
          { 
            progress: progress,
            lastUpdated: new Date()
          },
          { new: true }
        )
        .populate('createdBy', 'name email')
        .populate('assignments.user', 'name email avatar')
        .exec();

      return updatedProject;
    } catch (error) {
      this.logger.error(`Failed to update project progress for ${projectId}: ${error.message}`);
      throw error;
    }
  }

  async updateTimelinePhase(
    projectId: string, 
    phaseId: string, 
    updateData: Partial<{
      phase: string;
      description: string;
      startDate: Date;
      endDate: Date;
      status: string;
    }>, 
    userId: string
  ): Promise<Project> {
    try {
      const project = await this.findOne(projectId, userId);
      
      const setUpdate: any = {};
      if (updateData.phase) setUpdate['timeline.$[phase].phase'] = updateData.phase;
      if (updateData.description) setUpdate['timeline.$[phase].description'] = updateData.description;
      if (updateData.startDate) setUpdate['timeline.$[phase].startDate'] = updateData.startDate;
      if (updateData.endDate) setUpdate['timeline.$[phase].endDate'] = updateData.endDate;
      if (updateData.status) setUpdate['timeline.$[phase].status'] = updateData.status;

      const updatedProject = await this.projectModel
        .findByIdAndUpdate(
          projectId,
          { 
            $set: setUpdate,
            lastUpdated: new Date()
          },
          { 
            new: true,
            arrayFilters: [{ 'phase._id': new Types.ObjectId(phaseId) }]
          }
        )
        .populate('createdBy', 'name email')
        .populate('assignments.user', 'name email avatar')
        .exec();

      return updatedProject;
    } catch (error) {
      this.logger.error(`Failed to update timeline phase ${phaseId} in project ${projectId}: ${error.message}`);
      throw error;
    }
  }

  async markAsComplete(projectId: string, userId: string): Promise<Project> {
    try {
      const project = await this.findOne(projectId, userId);

      const updatedProject = await this.projectModel
        .findByIdAndUpdate(
          projectId,
          { 
            status: 'completed',
            lastUpdated: new Date()
          },
          { new: true }
        )
        .populate('createdBy', 'name email')
        .populate('assignments.user', 'name email avatar')
        .exec();

      // Get team member IDs
      const teamMemberIds = await this.getTeamMemberIds(project.teamId.toString());

      // Create notification
      await this.notificationsService.createProjectCompletedNotification(
        projectId,
        project.name,
        project.teamId.toString(),
        teamMemberIds,
        userId,
      );

      return updatedProject;
    } catch (error) {
      this.logger.error(`Failed to mark project ${projectId} as complete: ${error.message}`);
      throw error;
    }
  }

  private async verifyTeamMembership(teamId: string, userId: string): Promise<boolean> {
  try {
    // Implement proper team membership verification
    // This should check if user is a member of the team
    const team = await this.teamModel?.findById(teamId); // Note: you need to inject teamModel
    
    if (team) {
      const isMember = team.members.some(member => 
        member.user.toString() === userId
      );
      const isOwner = team.owner.toString() === userId;
      return isMember || isOwner;
    }
    
    return false;
  } catch (error) {
    this.logger.error(`Failed to verify team membership: ${error.message}`);
    return false;
  }
}
  private async getTeamMemberIds(teamId: string): Promise<string[]> {
    // TODO: Implement fetching team member IDs from teams service or model
    // For now, return empty array or stub
    return [];
  }
}