import { 
  Controller, 
  Get, 
  Put, 
  Delete, 
  Body, 
  Param, 
  UseGuards, 
  Query, 
  Post,
  HttpCode,
  HttpStatus
} from '@nestjs/common';
import { UsersService } from '../users.service';
import { UpdateProfileDto } from './update-profile.dto';
import { SearchUsersDto } from './search-users.dto';
import { AddSkillsDto, RemoveSkillsDto } from './skills.dto';
import { UserResponseDto, PublicUserResponseDto } from './user-response.dto';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../auth/decorators/roles.decorator';
import { Role } from '../../../auth/enums/role.enum';
import { CurrentUser } from '../../../auth/decorators/current-user.decorator';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';

@ApiTags('users')
@Controller('users')
@UseGuards(JwtAuthGuard, RolesGuard)
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

  @Post('skills')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Add skills to user profile' })
  @ApiResponse({ status: 200, description: 'Skills added successfully', type: UserResponseDto })
  async addSkills(
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

  @Get()
  @ApiOperation({ summary: 'Search and list users' })
  @ApiQuery({ name: 'query', required: false, type: String })
  @ApiQuery({ name: 'role', required: false, enum: Role })
  @ApiQuery({ name: 'skills', required: false, type: String, isArray: true })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Users retrieved successfully' })
  async searchUsers(@Query() searchDto: SearchUsersDto): Promise<{ users: PublicUserResponseDto[], total: number }> {
    return this.usersService.searchUsers(searchDto);
  }

  @Get('mentors/all')
  @ApiOperation({ summary: 'Get all public mentors' })
  @ApiResponse({ status: 200, description: 'Mentors retrieved successfully', type: [PublicUserResponseDto] })
  async getMentors(): Promise<PublicUserResponseDto[]> {
    return this.usersService.getMentors();
  }

  @Get('students/all')
  @ApiOperation({ summary: 'Get all public students' })
  @ApiResponse({ status: 200, description: 'Students retrieved successfully', type: [PublicUserResponseDto] })
  async getStudents(): Promise<PublicUserResponseDto[]> {
    return this.usersService.getStudents();
  }

  @Post('verify')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Request profile verification' })
  @ApiResponse({ status: 200, description: 'Verification request submitted' })
  async requestVerification(@CurrentUser() user: any): Promise<{ message: string }> {
    return this.usersService.requestVerification(user.userId);
  }
}