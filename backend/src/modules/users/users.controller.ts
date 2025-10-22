import { 
  Controller, 
  Get, 
  Put, 
  Delete, 
  Body, 
  Param, 
  UseGuards,
  HttpCode,
  HttpStatus
} from '@nestjs/common';
import { UsersService } from './users.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { AddSkillsDto, RemoveSkillsDto } from './dto/skills.dto';
import { UserResponseDto, PublicUserResponseDto } from './dto/user-response.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('users')
@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('profile')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current user profile' })
  @ApiResponse({ status: 200, description: 'User profile retrieved successfully', type: UserResponseDto })
  async getProfile(@CurrentUser() user: any): Promise<UserResponseDto> {
    return this.usersService.getProfile(user.userId);
  }

  @Put('profile')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update user profile' })
  @ApiResponse({ status: 200, description: 'Profile updated successfully', type: UserResponseDto })
  async updateProfile(
    @CurrentUser() user: any,
    @Body() updateProfileDto: UpdateProfileDto,
  ): Promise<UserResponseDto> {
    return this.usersService.updateProfile(user.userId, updateProfileDto);
  }

  @Delete('profile')
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete user account' })
  @ApiResponse({ status: 200, description: 'Account deleted successfully' })
  async deleteAccount(@CurrentUser() user: any): Promise<{ message: string }> {
    await this.usersService.deleteAccount(user.userId);
    return { message: 'Account deleted successfully' };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get public user profile' })
  @ApiResponse({ status: 200, description: 'Public profile retrieved successfully', type: PublicUserResponseDto })
  async getPublicProfile(@Param('id') id: string): Promise<PublicUserResponseDto> {
    return this.usersService.getPublicProfile(id);
  }

  @Put('skills')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update user skills' })
  @ApiResponse({ status: 200, description: 'Skills updated successfully', type: UserResponseDto })
  async updateSkills(
    @CurrentUser() user: any,
    @Body() addSkillsDto: AddSkillsDto,
  ): Promise<UserResponseDto> {
    return this.usersService.addSkills(user.userId, addSkillsDto.skills);
  }

  @Delete('skills')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Remove skills from user profile' })
  @ApiResponse({ status: 200, description: 'Skills removed successfully', type: UserResponseDto })
  async removeSkills(
    @CurrentUser() user: any,
    @Body() removeSkillsDto: RemoveSkillsDto,
  ): Promise<UserResponseDto> {
    return this.usersService.removeSkills(user.userId, removeSkillsDto.skills);
  }
}