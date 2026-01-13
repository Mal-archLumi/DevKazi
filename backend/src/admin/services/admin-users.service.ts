// admin/services/admin-users.service.ts - FIXED
import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { User, UserRole } from '../../modules/users/schemas/user.schema';
import { Team } from '../../modules/teams/schemas/team.schema';
import { Project } from '../../modules/projects/schemas/project.schema';

interface GetUsersOptions {
  page: number;
  limit: number;
  search?: string;
  role?: UserRole;
  isActive?: boolean;
}

@Injectable()
export class AdminUsersService {
  constructor(
    @InjectModel(User.name) private userModel: Model<User>,
    @InjectModel(Team.name) private teamModel: Model<Team>,
    @InjectModel(Project.name) private projectModel: Model<Project>,
  ) {}

  async getUsers(options: GetUsersOptions) {
    const { page, limit, search, role, isActive } = options;
    const skip = (page - 1) * limit;

    // Build query
    const query: any = {};

    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
        { skills: { $in: [new RegExp(search, 'i')] } },
      ];
    }

    if (role) {
      query.role = role;
    }

    if (isActive !== undefined) {
      query.isActive = isActive;
    }

    // Execute queries
    const [users, total] = await Promise.all([
      this.userModel
        .find(query)
        .select('-password -resetPasswordToken -resetPasswordExpires')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean(),
      this.userModel.countDocuments(query),
    ]);

    return {
      users,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    };
  }

  async getUserById(id: string) {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('Invalid user ID');
    }

    const user = await this.userModel
      .findById(id)
      .select('-password -resetPasswordToken -resetPasswordExpires')
      .lean();

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return user;
  }

  async updateUserRole(id: string, role: UserRole) {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('Invalid user ID');
    }

    const user = await this.userModel.findByIdAndUpdate(
      id,
      { role, updatedAt: new Date() },
      { new: true }
    ).select('-password -resetPasswordToken -resetPasswordExpires');

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return {
      message: `User role updated to ${role}`,
      user,
    };
  }

  async updateUserStatus(id: string, isActive: boolean) {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('Invalid user ID');
    }

    const user = await this.userModel.findByIdAndUpdate(
      id,
      { isActive, updatedAt: new Date() },
      { new: true }
    ).select('-password -resetPasswordToken -resetPasswordExpires');

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return {
      message: `User ${isActive ? 'activated' : 'deactivated'}`,
      user,
    };
  }

  async deactivateUser(id: string) {
    return this.updateUserStatus(id, false);
  }

  async getUserStats(userId: string) {
    if (!Types.ObjectId.isValid(userId)) {
      throw new BadRequestException('Invalid user ID');
    }

    const [teamCount, createdProjects, assignedProjects] = await Promise.all([
      // Count teams user is a member of
      this.teamModel.countDocuments({ 'members.user': new Types.ObjectId(userId) }),
      
      // Count projects created by user
      this.projectModel.countDocuments({ 
        createdBy: new Types.ObjectId(userId),
        isActive: true 
      }),
      
      // Count projects where user is assigned
      this.projectModel.countDocuments({
        'assignments.user': new Types.ObjectId(userId),
        isActive: true
      }),
    ]);

    // Get all projects where user is assigned to calculate progress
    const userProjects = await this.projectModel.find({
      'assignments.user': new Types.ObjectId(userId),
      isActive: true
    });

    let completedTasks = 0;
    let totalTasks = 0;

    userProjects.forEach(project => {
      project.assignments.forEach(assignment => {
        if (assignment.user?.toString() === userId) {
          // Parse tasks string to estimate completion
          const tasks = assignment.tasks?.split(',') || [];
          const completed = tasks.filter(t => t.trim().startsWith('[x]') || t.trim().startsWith('✓')).length;
          completedTasks += completed;
          totalTasks += tasks.length || 0;
        }
      });
    });

    const completionRate = totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0;

    return {
      userId,
      teamCount,
      createdProjects,
      assignedProjects,
      completedTasks,
      totalTasks,
      completionRate,
    };
  }
}