import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from './schemas/user.schema';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { UserResponseDto, PublicUserResponseDto } from './dto/user-response.dto';

@Injectable()
export class UsersService {
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
    const user = new this.userModel(userData);
    return user.save();
  }

  async update(id: string, updateData: Partial<User>): Promise<UserDocument | null> {
    return this.userModel.findByIdAndUpdate(id, updateData, { new: true });
  }

  // Profile management
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
      isActive: true,
      isProfilePublic: true,
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

  private mapToUserResponseDto(user: UserDocument): UserResponseDto {
    const userObj = user.toObject ? user.toObject() : user;
    
    return {
      _id: (userObj as any)._id?.toString() || '',
      email: userObj.email,
      name: userObj.name,
      skills: userObj.skills || [],
      bio: userObj.bio,
      education: userObj.education,
      avatar: userObj.avatar,
      isVerified: userObj.isVerified || false,
      isProfilePublic: userObj.isProfilePublic !== undefined ? userObj.isProfilePublic : true,
      isActive: userObj.isActive !== undefined ? userObj.isActive : true,
      createdAt: (userObj as any).createdAt || new Date(),
      updatedAt: (userObj as any).updatedAt || new Date(),
    };
  }

  private mapToPublicUserResponseDto(user: UserDocument): PublicUserResponseDto {
    const userObj = user.toObject ? user.toObject() : user;
    
    return {
      _id: (userObj as any)._id?.toString() || '',
      name: userObj.name,
      skills: userObj.skills || [],
      bio: userObj.bio,
      avatar: userObj.avatar,
      isVerified: userObj.isVerified || false,
    };
  }
}