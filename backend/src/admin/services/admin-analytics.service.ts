// admin/services/admin-analytics.service.ts - COMPLETE UPDATED VERSION
import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserRole } from '../../modules/users/schemas/user.schema';
import { Team } from '../../modules/teams/schemas/team.schema';
import { Project } from '../../modules/projects/schemas/project.schema';
import { Message } from '../../modules/chat/schemas/message.schema';

interface PlatformAnalytics {
  summary: {
    totalUsers: number;
    activeUsers: number;
    totalTeams: number;
    activeTeams: number;
    totalProjects: number;
    activeProjects: number;
    totalMessages: number;
  };
  growth: {
    newUsersToday: number;
    newUsersThisWeek: number;
    newUsersThisMonth: number;
    newTeamsToday: number;
    newProjectsToday: number;
    newMessagesToday: number;
  };
  metrics: {
    userActivityRate: number;
    teamEngagementRate: number;
    projectCompletionRate: number;
    averageMembersPerTeam: number;
    activeProjectRate: number;
  };
  breakdown: {
    usersByRole: Record<UserRole, number>;
    projectsByStatus: Record<string, number>;
  };
  timeline: {
    usersLast7Days: Array<{ date: string; count: number }>;
    projectsLast7Days: Array<{ date: string; count: number }>;
  };
}

interface TimelineDataPoint {
  date: string;
  users: number;
  teams: number;
  projects: number;
}

@Injectable()
export class AdminAnalyticsService {
  private readonly logger = new Logger(AdminAnalyticsService.name);

  constructor(
    @InjectModel(User.name) private userModel: Model<User>,
    @InjectModel(Team.name) private teamModel: Model<Team>,
    @InjectModel(Project.name) private projectModel: Model<Project>,
    @InjectModel(Message.name) private messageModel: Model<Message>,
  ) {}

  async getPlatformAnalytics(): Promise<PlatformAnalytics> {
    try {
      this.logger.log('🔄 Calculating platform analytics...');
      
      const now = new Date();
      const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      const startOfWeek = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 7);
      const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
      const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

      // Get active teams - SIMPLIFIED AND MORE ACCURATE LOGIC
      const activeTeams = await this.teamModel.countDocuments({
        $or: [
          { 
            isActive: true,
            'members.0': { $exists: true } // Has at least one member
          },
          {
            isActive: true,
            lastActivity: { $gte: thirtyDaysAgo } // Recent activity
          },
          {
            isActive: true,
            createdAt: { $gte: thirtyDaysAgo } // Recently created
          }
        ]
      });

      this.logger.log(`✅ Found ${activeTeams} active teams`);

      // Get messages today
      const messagesToday = await this.messageModel.countDocuments({
        createdAt: { $gte: startOfToday }
      });

      // Execute all queries in parallel for performance
      const [
        totalUsers,
        activeUsers,
        totalTeams,
        totalProjects,
        activeProjects,
        totalMessages,
        newUsersToday,
        newUsersThisWeek,
        newUsersThisMonth,
        newTeamsToday,
        newProjectsToday,
        usersByRole,
        projectsByStatus,
      ] = await Promise.all([
        // Summary counts
        this.userModel.countDocuments({}),
        this.userModel.countDocuments({ isActive: true }),
        this.teamModel.countDocuments({}),
        this.projectModel.countDocuments({}),
        this.projectModel.countDocuments({ isActive: true }),
        this.messageModel.countDocuments({}),

        // Growth metrics
        this.userModel.countDocuments({ createdAt: { $gte: startOfToday } }),
        this.userModel.countDocuments({ createdAt: { $gte: startOfWeek } }),
        this.userModel.countDocuments({ createdAt: { $gte: startOfMonth } }),
        this.teamModel.countDocuments({ createdAt: { $gte: startOfToday } }),
        this.projectModel.countDocuments({ createdAt: { $gte: startOfToday } }),

        // Breakdowns
        this.userModel.aggregate([
          { $group: { _id: '$role', count: { $sum: 1 } } },
        ]),
        this.projectModel.aggregate([
          { $group: { _id: '$status', count: { $sum: 1 } } },
        ]),
      ]);

      // Get completed projects count
      const completedProjects = await this.projectModel.countDocuments({ 
        status: 'completed',
        isActive: true 
      });

      // Calculate metrics
      const userActivityRate = totalUsers > 0 ? Math.round((activeUsers / totalUsers) * 100) : 0;
      const teamEngagementRate = totalTeams > 0 ? Math.round((activeTeams / totalTeams) * 100) : 0;
      const projectCompletionRate = totalProjects > 0 
        ? Math.round((completedProjects / totalProjects) * 100) 
        : 0;
      const activeProjectRate = totalProjects > 0 
        ? Math.round((activeProjects / totalProjects) * 100) 
        : 0;

      // Get average members per team
      const teamStats = await this.teamModel.aggregate([
        { 
          $project: { 
            memberCount: { 
              $cond: {
                if: { $isArray: "$members" },
                then: { $size: "$members" },
                else: 0
              }
            } 
          } 
        },
        { $group: { _id: null, avgMembers: { $avg: '$memberCount' }, totalTeams: { $sum: 1 } } },
      ]);

      const averageMembersPerTeam = teamStats.length > 0 && teamStats[0].avgMembers !== null
        ? parseFloat(teamStats[0].avgMembers.toFixed(1)) 
        : 0;

      // Format users by role
      const usersByRoleObj = Object.values(UserRole).reduce((acc, role) => {
        acc[role] = 0;
        return acc;
      }, {} as Record<UserRole, number>);

      usersByRole.forEach((item: any) => {
        if (item._id && usersByRoleObj.hasOwnProperty(item._id)) {
          usersByRoleObj[item._id] = item.count;
        }
      });

      // Format projects by status
      const projectsByStatusObj = {
        active: 0,
        completed: 0,
        archived: 0,
        inactive: 0,
      };

      projectsByStatus.forEach((item: any) => {
        if (item._id && projectsByStatusObj.hasOwnProperty(item._id)) {
          projectsByStatusObj[item._id] = item.count;
        }
      });

      // Get timeline data for last 7 days
      const last7Days = Array.from({ length: 7 }, (_, i) => {
        const date = new Date();
        date.setDate(date.getDate() - i);
        return date.toISOString().split('T')[0];
      }).reverse();

      const [usersTimeline, projectsTimeline] = await Promise.all([
        this.userModel.aggregate([
          {
            $match: {
              createdAt: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) },
            },
          },
          {
            $group: {
              _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
              count: { $sum: 1 },
            },
          },
          { $sort: { _id: 1 } },
        ]),
        this.projectModel.aggregate([
          {
            $match: {
              createdAt: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) },
            },
          },
          {
            $group: {
              _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
              count: { $sum: 1 },
            },
          },
          { $sort: { _id: 1 } },
        ]),
      ]);

      // Format timeline data
      const usersLast7Days = last7Days.map(date => {
        const found = usersTimeline.find(item => item._id === date);
        return { date, count: found ? found.count : 0 };
      });

      const projectsLast7Days = last7Days.map(date => {
        const found = projectsTimeline.find(item => item._id === date);
        return { date, count: found ? found.count : 0 };
      });

      const result = {
        summary: {
          totalUsers,
          activeUsers,
          totalTeams,
          activeTeams,
          totalProjects,
          activeProjects,
          totalMessages,
        },
        growth: {
          newUsersToday,
          newUsersThisWeek,
          newUsersThisMonth,
          newTeamsToday,
          newProjectsToday,
          newMessagesToday: messagesToday,
        },
        metrics: {
          userActivityRate,
          teamEngagementRate,
          projectCompletionRate,
          averageMembersPerTeam,
          activeProjectRate,
        },
        breakdown: {
          usersByRole: usersByRoleObj,
          projectsByStatus: projectsByStatusObj,
        },
        timeline: {
          usersLast7Days,
          projectsLast7Days,
        },
      };

      this.logger.log('✅ Platform analytics calculated successfully');
      this.logger.debug('Analytics result:', JSON.stringify(result.summary));

      return result;
      
    } catch (error) {
      this.logger.error('❌ Failed to calculate platform analytics:', error);
      throw error;
    }
  }

  async getBasicAnalytics() {
    try {
      const analytics = await this.getPlatformAnalytics();
      
      // Return only basic analytics for dashboard
      return {
        summary: analytics.summary,
        metrics: analytics.metrics,
        growth: analytics.growth,
      };
    } catch (error) {
      this.logger.error('❌ Failed to get basic analytics:', error);
      throw error;
    }
  }

  async getTimelineData(range: 'week' | 'month' | 'year'): Promise<TimelineDataPoint[]> {
    try {
      this.logger.log(`🔄 Getting timeline data for range: ${range}`);
      
      const now = new Date();
      let startDate = new Date();
      let dateFormat = '%Y-%m-%d';
      let daysCount = 7;

      if (range === 'month') {
        startDate.setDate(startDate.getDate() - 30);
        daysCount = 30;
      } else if (range === 'year') {
        startDate.setFullYear(startDate.getFullYear() - 1);
        dateFormat = '%Y-%m';
        daysCount = 12;
      } else {
        startDate.setDate(startDate.getDate() - 7);
        daysCount = 7;
      }

      // Execute all timeline queries in parallel
      const [usersTimeline, teamsTimeline, projectsTimeline] = await Promise.all([
        this.userModel.aggregate([
          {
            $match: {
              createdAt: { $gte: startDate },
            },
          },
          {
            $group: {
              _id: { $dateToString: { format: dateFormat, date: '$createdAt' } },
              count: { $sum: 1 },
            },
          },
          { $sort: { _id: 1 } },
        ]),
        this.teamModel.aggregate([
          {
            $match: {
              createdAt: { $gte: startDate },
            },
          },
          {
            $group: {
              _id: { $dateToString: { format: dateFormat, date: '$createdAt' } },
              count: { $sum: 1 },
            },
          },
          { $sort: { _id: 1 } },
        ]),
        this.projectModel.aggregate([
          {
            $match: {
              createdAt: { $gte: startDate },
            },
          },
          {
            $group: {
              _id: { $dateToString: { format: dateFormat, date: '$createdAt' } },
              count: { $sum: 1 },
            },
          },
          { $sort: { _id: 1 } },
        ]),
      ]);

      // Create a map to store all data points
      const dataMap = new Map<string, { users: number; teams: number; projects: number }>();

      // Initialize data for all periods
      for (let i = 0; i < daysCount; i++) {
        const date = new Date();
        
        if (range === 'year') {
          date.setMonth(date.getMonth() - (daysCount - 1 - i));
          const label = date.toLocaleDateString('en-US', { month: 'short' });
          dataMap.set(label, { users: 0, teams: 0, projects: 0 });
        } else {
          date.setDate(date.getDate() - (daysCount - 1 - i));
          const label = range === 'month' 
            ? date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
            : date.toLocaleDateString('en-US', { weekday: 'short' });
          
          const dateKey = range === 'month' 
            ? date.toISOString().split('T')[0]
            : date.toLocaleDateString('en-US', { weekday: 'short' });
            
          dataMap.set(dateKey, { users: 0, teams: 0, projects: 0 });
        }
      }

      // Fill in user data
      usersTimeline.forEach(item => {
        let key: string;
        if (range === 'year') {
          key = new Date(item._id + '-01').toLocaleDateString('en-US', { month: 'short' });
        } else if (range === 'month') {
          key = item._id;
        } else {
          key = new Date(item._id).toLocaleDateString('en-US', { weekday: 'short' });
        }
        
        const existing = dataMap.get(key) || { users: 0, teams: 0, projects: 0 };
        existing.users = item.count;
        dataMap.set(key, existing);
      });

      // Fill in team data
      teamsTimeline.forEach(item => {
        let key: string;
        if (range === 'year') {
          key = new Date(item._id + '-01').toLocaleDateString('en-US', { month: 'short' });
        } else if (range === 'month') {
          key = item._id;
        } else {
          key = new Date(item._id).toLocaleDateString('en-US', { weekday: 'short' });
        }
        
        const existing = dataMap.get(key) || { users: 0, teams: 0, projects: 0 };
        existing.teams = item.count;
        dataMap.set(key, existing);
      });

      // Fill in project data
      projectsTimeline.forEach(item => {
        let key: string;
        if (range === 'year') {
          key = new Date(item._id + '-01').toLocaleDateString('en-US', { month: 'short' });
        } else if (range === 'month') {
          key = item._id;
        } else {
          key = new Date(item._id).toLocaleDateString('en-US', { weekday: 'short' });
        }
        
        const existing = dataMap.get(key) || { users: 0, teams: 0, projects: 0 };
        existing.projects = item.count;
        dataMap.set(key, existing);
      });

      // Convert to array format sorted by date
      const result = Array.from(dataMap.entries())
        .map(([date, counts]) => ({
          date,
          users: counts.users,
          teams: counts.teams,
          projects: counts.projects,
        }))
        .sort((a, b) => {
          // Simple sort for week view (Mon, Tue, Wed, etc.)
          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          if (days.includes(a.date) && days.includes(b.date)) {
            return days.indexOf(a.date) - days.indexOf(b.date);
          }
          // For month/year views, maintain existing order
          return 0;
        });

      this.logger.log(`✅ Timeline data retrieved: ${result.length} data points`);
      return result;
      
    } catch (error) {
      this.logger.error('❌ Failed to get timeline data:', error);
      throw error;
    }
  }
}