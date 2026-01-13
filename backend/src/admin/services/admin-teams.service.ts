// admin/services/admin-teams.service.ts - FIXED
import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Team } from '../../modules/teams/schemas/team.schema';
import { Project } from '../../modules/projects/schemas/project.schema';

interface GetTeamsOptions {
  page: number;
  limit: number;
  search?: string;
}

@Injectable()
export class AdminTeamsService {
  constructor(
    @InjectModel(Team.name) private teamModel: Model<Team>,
    @InjectModel(Project.name) private projectModel: Model<Project>,
  ) {}

  async getTeams(options: GetTeamsOptions) {
    const { page, limit, search } = options;
    const skip = (page - 1) * limit;

    const query: any = {};
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
      ];
    }

    const [teams, total] = await Promise.all([
      this.teamModel
        .find(query)
        .populate('owner', 'name email')
        .populate('members.user', 'name email')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean(),
      this.teamModel.countDocuments(query),
    ]);

    return {
      teams,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    };
  }

  async getTeamById(id: string) {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('Invalid team ID');
    }

    const team = await this.teamModel
      .findById(id)
      .populate('owner', 'name email')
      .populate('members.user', 'name email skills')
      .lean();

    if (!team) {
      throw new NotFoundException('Team not found');
    }

    return team;
  }

  async getTeamProjects(teamId: string) {
    if (!Types.ObjectId.isValid(teamId)) {
      throw new BadRequestException('Invalid team ID');
    }

    const projects = await this.projectModel
      .find({ 
        teamId: new Types.ObjectId(teamId),
        isActive: true 
      })
      .populate('createdBy', 'name email')
      .sort({ lastUpdated: -1 })
      .lean();

    // Calculate project stats based on assignments
    const projectStats = projects.map(project => {
      let totalAssignments = 0;
      let completedAssignments = 0;

      project.assignments?.forEach(assignment => {
        totalAssignments++;
        // Simple check for completion based on tasks string
        if (assignment.tasks && assignment.tasks.includes('[x]') || assignment.tasks.includes('✓')) {
          completedAssignments++;
        }
      });

      const completionRate = totalAssignments > 0 
        ? Math.round((completedAssignments / totalAssignments) * 100) 
        : 0;

      return {
        ...project,
        stats: {
          totalAssignments,
          completedAssignments,
          completionRate,
          timelinePhases: project.timeline?.length || 0,
          activePhases: project.timeline?.filter(p => p.status === 'in-progress')?.length || 0,
          completedPhases: project.timeline?.filter(p => p.status === 'completed')?.length || 0,
        }
      };
    });

    return {
      teamId,
      projects: projectStats,
      total: projects.length,
      summary: {
        activeProjects: projects.filter(p => p.status === 'active').length,
        completedProjects: projects.filter(p => p.status === 'completed').length,
        averageCompletion: projectStats.length > 0 
          ? Math.round(projectStats.reduce((sum, p) => sum + p.stats.completionRate, 0) / projectStats.length)
          : 0,
      }
    };
  }
}