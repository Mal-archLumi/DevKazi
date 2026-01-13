import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument, UserRole } from './schemas/user.schema';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { UserResponseDto, PublicUserResponseDto } from './dto/user-response.dto';

@Injectable()
export class UsersService {
  logger: any;
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
  ) {}

  // Basic user operations
  async findByEmail(email: string): Promise<UserDocument | null> {
    return this.userModel.findOne({ email: email.toLowerCase() });
  }

  async findById(id: string): Promise<UserDocument | null> {
    return this.userModel.findById(id);
  }

  async create(userData: Partial<User>): Promise<UserDocument> {
    const user = await this.userModel.create({
      ...userData,
      role: userData.role || UserRole.USER,
      permissions: userData.permissions || [],
    });
    return user;
  }

  async update(id: string, updateData: Partial<User>): Promise<UserDocument | null> {
    return this.userModel.findByIdAndUpdate(id, updateData, { new: true });
  }

  // Profile management
  async getProfile(userId: string): Promise<UserResponseDto> {
    const user = await this.userModel
      .findById(userId)
      .select('+teamCount +projectCount') // Select virtual fields
      .exec();
    
    if (!user) {
      throw new NotFoundException('User not found');
    }
    
    return this.mapToUserResponseDto(user);
  }

  async getPublicProfile(userId: string): Promise<PublicUserResponseDto> {
    const user = await this.userModel
      .findOne({
        _id: userId,
        isActive: true,
        isProfilePublic: true,
      })
      .select('+teamCount')
      .exec();

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
  
  // IMPORTANT: We do NOT delete the user document completely
  // Instead, we anonymize it and mark as inactive
  
  const deletedEmail = `deleted-${Date.now()}-${user.email}`;
  
  await this.userModel.findByIdAndUpdate(userId, {
    isActive: false,
    email: deletedEmail,
    name: 'Deleted User',
    picture: null,
    bio: '',
    skills: [],
    isProfilePublic: false,
    updatedAt: new Date(),
    // Keep the original _id so messages can still reference this user
  }, { new: true });
  
  this.logger.log(`User account anonymized: ${userId} -> ${deletedEmail}`);
  
  // Note: User's messages will remain in the database
  // but will show "Deleted User" when populated
}

  // Skills management
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

  // Helper methods
  private validateSkills(skills: string[]): string[] {
    // Simple validation - just trim and filter empty skills
    const validatedSkills = skills
      .map(skill => skill.trim())
      .filter(skill => skill.length > 0);

    if (validatedSkills.length === 0) {
      throw new BadRequestException('No valid skills provided');
    }

    return validatedSkills;
  }

  private async mapToUserResponseDto(user: UserDocument): Promise<UserResponseDto> {
    // Populate virtual fields if needed
    const userWithVirtuals = await user.populate(['teamCount', 'projectCount']);
    
    return {
      _id: userWithVirtuals._id.toString(),
      email: userWithVirtuals.email,
      name: userWithVirtuals.name,
      skills: userWithVirtuals.skills || [],
      bio: userWithVirtuals.bio,
      education: userWithVirtuals.education,
      picture: (userWithVirtuals as any).picture || userWithVirtuals.avatar,
      isVerified: userWithVirtuals.isVerified || false,
      isProfilePublic: userWithVirtuals.isProfilePublic !== undefined ? userWithVirtuals.isProfilePublic : true,
      isActive: userWithVirtuals.isActive !== undefined ? userWithVirtuals.isActive : true,
      createdAt: userWithVirtuals.createdAt || new Date(),
      updatedAt: userWithVirtuals.updatedAt || new Date(),
      teamCount: (userWithVirtuals as any).teamCount || 0,
      projectCount: (userWithVirtuals as any).projectCount || 0,
    };
  }

  private async mapToPublicUserResponseDto(user: UserDocument): Promise<PublicUserResponseDto> {
    const userWithVirtuals = await user.populate('teamCount');
    
    return {
      _id: userWithVirtuals._id.toString(),
      name: userWithVirtuals.name,
      skills: userWithVirtuals.skills || [],
      bio: userWithVirtuals.bio,
      picture: (userWithVirtuals as any).picture || userWithVirtuals.avatar,
      isVerified: userWithVirtuals.isVerified || false,
      teamCount: (userWithVirtuals as any).teamCount || 0,
    };
  }
}