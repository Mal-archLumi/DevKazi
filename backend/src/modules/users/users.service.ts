import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from './schemas/user.schema';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { UserResponseDto, PublicUserResponseDto } from './dto/user-response.dto';
import { SearchUsersDto } from './dto/search-users.dto';
import { Role } from '../../auth/enums/role.enum';

@Injectable()
export class UsersService {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
  ) {}

  // ✅ PRESERVED: Original methods for backward compatibility
  async findByEmail(email: string): Promise<UserDocument | null> {
    return this.userModel.findOne({ email: email.toLowerCase() });
  }

  async findById(id: string): Promise<UserDocument | null> {
    return this.userModel.findById(id);
  }

  async create(userData: Partial<User>): Promise<UserDocument> {
    const user = new this.userModel(userData);
    return user.save();
  }

  async update(id: string, updateData: Partial<User>): Promise<UserDocument | null> {
    return this.userModel.findByIdAndUpdate(id, updateData, { new: true });
  }

  // ✅ NEW: Enhanced profile methods
  async getProfile(userId: string): Promise<UserResponseDto> {
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return this.mapToUserResponseDto(user);
  }

  async getPublicProfile(userId: string): Promise<PublicUserResponseDto> {
    const user = await this.userModel.findOne({
      _id: userId,
      $and: [
        {
          $or: [
            { isActive: true },
            { isActive: { $exists: false } }
          ]
        },
        {
          $or: [
            { isProfilePublic: true },
            { isProfilePublic: { $exists: false } }
          ]
        }
      ]
    });

    if (!user) {
      throw new NotFoundException('User not found or profile is private');
    }

    return this.mapToPublicUserResponseDto(user);
  }

  async updateProfile(userId: string, updateData: UpdateProfileDto): Promise<UserResponseDto> {
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Use roles array instead of role field
    if (updateData.role && user.roles && user.roles.length > 0 && updateData.role !== user.roles[0]) {
      throw new ForbiddenException('Cannot change role through profile update');
    }

    // Prevent email duplication
    if (updateData.email && updateData.email !== user.email) {
      const existingUser = await this.userModel.findOne({ email: updateData.email.toLowerCase() });
      if (existingUser) {
        throw new BadRequestException('Email already exists');
      }
      updateData.email = updateData.email.toLowerCase();
    }

    const updatedUser = await this.userModel.findByIdAndUpdate(
      userId,
      { ...updateData, updatedAt: new Date() },
      { new: true, runValidators: true }
    );

    if (!updatedUser) {
      throw new NotFoundException('User not found during update');
    }

    return this.mapToUserResponseDto(updatedUser);
  }

  async deleteAccount(userId: string): Promise<void> {
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    
    // Soft delete
    await this.userModel.findByIdAndUpdate(userId, {
      isActive: false,
      email: `deleted-${Date.now()}-${user.email}`,
      updatedAt: new Date(),
    });
  }

  async addSkills(userId: string, skills: string[]): Promise<UserResponseDto> {
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    
    const validatedSkills = this.validateSkills(skills);
    const currentSkills = user.skills || [];
    const uniqueSkills = [...new Set([...currentSkills, ...validatedSkills])];

    const updatedUser = await this.userModel.findByIdAndUpdate(
      userId,
      { skills: uniqueSkills, updatedAt: new Date() },
      { new: true }
    );

    if (!updatedUser) {
      throw new NotFoundException('User not found during update');
    }

    return this.mapToUserResponseDto(updatedUser);
  }

  async removeSkills(userId: string, skills: string[]): Promise<UserResponseDto> {
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    
    const currentSkills = user.skills || [];
    const updatedSkills = currentSkills.filter(skill => !skills.includes(skill));
    
    const updatedUser = await this.userModel.findByIdAndUpdate(
      userId,
      { skills: updatedSkills, updatedAt: new Date() },
      { new: true }
    );

    if (!updatedUser) {
      throw new NotFoundException('User not found during update');
    }

    return this.mapToUserResponseDto(updatedUser);
  }

  async searchUsers(searchDto: SearchUsersDto): Promise<{ users: PublicUserResponseDto[], total: number }> {
    const page = searchDto.page || 1;
    const limit = searchDto.limit || 10;
    const skip = (page - 1) * limit;

    const filter: any = { 
      $and: [
        {
          $or: [
            { isActive: true },
            { isActive: { $exists: false } }
          ]
        },
        {
          $or: [
            { isProfilePublic: true },
            { isProfilePublic: { $exists: false } }
          ]
        }
      ]
    };

    if (searchDto.role) filter.role = searchDto.role;
    if (searchDto.verifiedOnly) filter.isVerified = true;
    if (searchDto.skills && searchDto.skills.length > 0) {
      filter.skills = { $in: searchDto.skills.map(skill => new RegExp(skill, 'i')) };
    }

    if (searchDto.query) {
      filter.$or = [
        { name: { $regex: searchDto.query, $options: 'i' } },
        { bio: { $regex: searchDto.query, $options: 'i' } },
        { education: { $regex: searchDto.query, $options: 'i' } },
        { skills: { $in: [new RegExp(searchDto.query, 'i')] } }
      ];
    }

    const [users, total] = await Promise.all([
      this.userModel
        .find(filter)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .exec(),
      this.userModel.countDocuments(filter),
    ]);

    return {
      users: users.map(user => this.mapToPublicUserResponseDto(user)),
      total,
    };
  }

  async getMentors(): Promise<PublicUserResponseDto[]> {
    const mentors = await this.userModel.find({
      roles: Role.MENTOR,
      $and: [
        {
          $or: [
            { isActive: true },
            { isActive: { $exists: false } }
          ]
        },
        {
          $or: [
            { isProfilePublic: true },
            { isProfilePublic: { $exists: false } }
          ]
        }
      ]
    });

    return mentors.map(mentor => this.mapToPublicUserResponseDto(mentor));
  }

  async getStudents(): Promise<PublicUserResponseDto[]> {
    const students = await this.userModel.find({
      roles: Role.STUDENT,
      $and: [
        {
          $or: [
            { isActive: true },
            { isActive: { $exists: false } }
          ]
        },
        {
          $or: [
            { isProfilePublic: true },
            { isProfilePublic: { $exists: false } }
          ]
        }
      ]
    });

    return students.map(student => this.mapToPublicUserResponseDto(student));
  }

  async requestVerification(userId: string): Promise<{ message: string }> {
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    
    console.log(`Verification requested for user: ${user.email}`);
    
    return { message: 'Verification request submitted. An admin will review your profile.' };
  }

  private validateSkills(skills: string[]): string[] {
    const validSkills = [
      'JavaScript', 'TypeScript', 'Python', 'Java', 'C#', 'C++', 'Ruby', 'Go',
      'React', 'Angular', 'Vue', 'Node.js', 'Express', 'NestJS', 'Django', 'Spring',
      'MongoDB', 'PostgreSQL', 'MySQL', 'Redis', 'Docker', 'Kubernetes', 'AWS', 'Azure',
      'Git', 'REST API', 'GraphQL', 'Machine Learning', 'Data Science', 'DevOps'
    ];

    const validatedSkills = skills.filter(skill => 
      validSkills.some(validSkill => 
        validSkill.toLowerCase() === skill.trim().toLowerCase()
      )
    );

    if (validatedSkills.length === 0) {
      throw new BadRequestException('No valid skills provided');
    }

    return validatedSkills.map(skill => 
      validSkills.find(validSkill => 
        validSkill.toLowerCase() === skill.trim().toLowerCase()
      )
    ).filter((skill): skill is string => skill !== undefined);
  }

  private mapToUserResponseDto(user: UserDocument): UserResponseDto {
    const userObj = user.toObject ? user.toObject() : user;
    
    return {
      _id: (userObj as any)._id?.toString() || '',
      email: userObj.email,
      name: userObj.name,
      role: (userObj.roles && userObj.roles.length > 0) ? userObj.roles[0] : Role.STUDENT,
      bio: userObj.bio,
      education: userObj.education,
      skills: userObj.skills || [],
      avatar: userObj.avatar,
      isVerified: userObj.isVerified || false,
      isProfilePublic: userObj.isProfilePublic !== undefined ? userObj.isProfilePublic : true,
      company: userObj.company,
      position: userObj.position,
      github: userObj.github,
      linkedin: userObj.linkedin,
      portfolio: userObj.portfolio,
      experienceYears: userObj.experienceYears || 0,
      createdAt: (userObj as any).createdAt || new Date(),
      updatedAt: (userObj as any).updatedAt || new Date(),
    };
  }

  private mapToPublicUserResponseDto(user: UserDocument): PublicUserResponseDto {
    const userObj = user.toObject ? user.toObject() : user;
    
    return {
      _id: (userObj as any)._id?.toString() || '',
      name: userObj.name,
      role: (userObj.roles && userObj.roles.length > 0) ? userObj.roles[0] : Role.STUDENT,
      bio: userObj.bio,
      skills: userObj.skills || [],
      avatar: userObj.avatar,
      isVerified: userObj.isVerified || false,
      company: userObj.company,
      position: userObj.position,
      experienceYears: userObj.experienceYears || 0,
    };
  }
}