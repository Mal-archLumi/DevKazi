// admin/services/admin-projects.service.ts
import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Project } from '../../modules/projects/schemas/project.schema';
import { Team } from '../../modules/teams/schemas/team.schema';
import { User } from '../../modules/users/schemas/user.schema';

interface GetProjectsOptions {
  page: number;
  limit: number;
  search?: string;
  status?: string;
  teamId?: string;
  isActive?: boolean;
}

@Injectable()
export class AdminProjectsService {
  constructor(
    @InjectModel(Project.name) private projectModel: Model<Project>,
    @InjectModel(Team.name) private teamModel: Model<Team>,
    @InjectModel(User.name) private userModel: Model<User>,
  ) {}

  async getProjects(options: GetProjectsOptions) {
    const { page, limit, search, status, teamId, isActive } = options;
    const skip = (page - 1) * limit;

    const query: any = {};

    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
      ];
    }

    if (status) {
      query.status = status;
    }

    if (teamId && Types.ObjectId.isValid(teamId)) {
      query.teamId = new Types.ObjectId(teamId);
    }

    if (isActive !== undefined) {
      query.isActive = isActive;
    }

    const [projects, total] = await Promise.all([
      this.projectModel
        .find(query)
        .populate('createdBy', 'name email')
        .populate('teamId', 'name')
        .populate('assignments.user', 'name email')
        .sort({ lastUpdated: -1 })
        .skip(skip)
        .limit(limit)
        .lean(),
      this.projectModel.countDocuments(query),
    ]);

    // Enhance projects with additional stats
    const enhancedProjects = projects.map(project => {
      // Calculate assignment stats
      const totalAssignments = project.assignments?.length || 0;
      const completedAssignments = project.assignments?.filter(assignment => {
        if (!assignment.tasks) return false;
        return assignment.tasks.includes('[x]') || assignment.tasks.includes('✓');
      }).length || 0;

      // Calculate timeline stats
      const timelinePhases = project.timeline?.length || 0;
      const completedPhases = project.timeline?.filter(phase => phase.status === 'completed').length || 0;
      const activePhases = project.timeline?.filter(phase => phase.status === 'in-progress').length || 0;

      return {
        ...project,
        stats: {
          totalAssignments,
          completedAssignments,
          completionRate: totalAssignments > 0 ? Math.round((completedAssignments / totalAssignments) * 100) : 0,
          timelinePhases,
          completedPhases,
          activePhases,
          timelineCompletionRate: timelinePhases > 0 ? Math.round((completedPhases / timelinePhases) * 100) : 0,
          totalIdeas: project.ideas?.length || 0,
          totalPinnedLinks: project.pinnedLinks?.length || 0,
        }
      };
    });

    return {
      projects: enhancedProjects,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    };
  }

  async getProjectById(id: string) {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('Invalid project ID');
    }

    const project = await this.projectModel
      .findById(id)
      .populate('createdBy', 'name email')
      .populate('teamId', 'name description')
      .populate('assignments.user', 'name email skills')
      .populate('pinnedLinks.pinnedBy', 'name email')
      .populate('ideas.createdBy', 'name email')
      .lean();

    if (!project) {
      throw new NotFoundException('Project not found');
    }

    // Calculate detailed stats
    const assignmentsByUser: Record<string, any> = {};
    let totalTasks = 0;
    let completedTasks = 0;

    project.assignments?.forEach(assignment => {
      const userId = assignment.user?._id?.toString();
      if (userId) {
        if (!assignmentsByUser[userId]) {
          assignmentsByUser[userId] = {
            user: assignment.user,
            assignments: 0,
            completed: 0,
          };
        }
        assignmentsByUser[userId].assignments++;
        
        // Parse tasks string
        const tasks = assignment.tasks?.split(',') || [];
        tasks.forEach(task => {
          const trimmed = task.trim();
          if (trimmed) {
            totalTasks++;
            if (trimmed.startsWith('[x]') || trimmed.startsWith('✓')) {
              completedTasks++;
              assignmentsByUser[userId].completed++;
            }
          }
        });
      }
    });

    const timelineStats = {
      total: project.timeline?.length || 0,
      completed: project.timeline?.filter(p => p.status === 'completed').length || 0,
      inProgress: project.timeline?.filter(p => p.status === 'in-progress').length || 0,
      planned: project.timeline?.filter(p => p.status === 'planned').length || 0,
    };

    return {
      ...project,
      detailedStats: {
        assignmentsByUser: Object.values(assignmentsByUser),
        totalTasks,
        completedTasks,
        taskCompletionRate: totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0,
        timelineStats,
        ideasCount: project.ideas?.length || 0,
        pinnedLinksCount: project.pinnedLinks?.length || 0,
        progress: project.progress || 0,
      }
    };
  }

  async updateProjectStatus(id: string, status: string) {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('Invalid project ID');
    }

    const validStatuses = ['active', 'inactive', 'completed', 'archived'];
    if (!validStatuses.includes(status)) {
      throw new BadRequestException(`Invalid status. Must be one of: ${validStatuses.join(', ')}`);
    }

    const project = await this.projectModel.findByIdAndUpdate(
      id,
      { 
        status, 
        lastUpdated: new Date(),
        ...(status === 'completed' ? { progress: 100 } : {})
      },
      { new: true }
    )
    .populate('createdBy', 'name email')
    .populate('teamId', 'name')
    .lean();

    if (!project) {
      throw new NotFoundException('Project not found');
    }

    return {
      message: `Project status updated to ${status}`,
      project,
    };
  }

  async deactivateProject(id: string) {
    return this.updateProjectStatus(id, 'inactive');
  }

  async getProjectInsights() {
    // Get overall project statistics
    const [
      totalProjects,
      activeProjects,
      completedProjects,
      projectsByTeam,
      recentProjects,
      stalledProjects,
    ] = await Promise.all([
      this.projectModel.countDocuments({}),
      this.projectModel.countDocuments({ status: 'active', isActive: true }),
      this.projectModel.countDocuments({ status: 'completed', isActive: true }),
      
      // Projects grouped by team
      this.projectModel.aggregate([
        { $match: { isActive: true } },
        { $group: { _id: '$teamId', count: { $sum: 1 } } },
        { $sort: { count: -1 } },
        { $limit: 10 },
      ]),
      
      // Recent projects (last 7 days)
      this.projectModel.countDocuments({ 
        createdAt: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) } 
      }),
      
      // Projects with no updates in 30 days
      this.projectModel.countDocuments({ 
        lastUpdated: { $lte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) },
        status: 'active',
        isActive: true 
      }),
    ]);

    // Get teams for the top projects
    const teamIds = projectsByTeam.map(p => p._id);
    const teams = await this.teamModel.find({ _id: { $in: teamIds } }, 'name');

    // Map team names to counts
    const projectsByTeamWithNames = projectsByTeam.map(item => {
      const team = teams.find(t => t._id.toString() === item._id.toString());
      return {
        teamId: item._id,
        teamName: team?.name || 'Unknown Team',
        count: item.count,
      };
    });

    return {
      overview: {
        totalProjects,
        activeProjects,
        completedProjects,
        completionRate: totalProjects > 0 ? Math.round((completedProjects / totalProjects) * 100) : 0,
        activeRate: totalProjects > 0 ? Math.round((activeProjects / totalProjects) * 100) : 0,
        recentProjects,
        stalledProjects,
      },
      distribution: {
        byTeam: projectsByTeamWithNames,
      },
    };
  }
}