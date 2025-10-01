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
  HttpStatus,
  Req,
  Request
} from '@nestjs/common';
import { UsersService } from './users.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { SearchUsersDto } from './dto/search-users.dto';
import { AddSkillsDto, RemoveSkillsDto } from './dto/skills.dto';
import { UserResponseDto, PublicUserResponseDto } from './dto/user-response.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';

@ApiTags('users')
@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  // ✅ PRESERVED: Old endpoint for backward compatibility
  @Get('me')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current user profile (legacy)' })
  async getCurrentUser(@Req() req: any) {
    const user = await this.usersService.findById(req.user.userId);
    if (!user) {
      return { message: 'User not found' };
    }
    const { password, ...result } = user.toObject();
    return result;
  }

  // ✅ NEW: Enhanced profile endpoint with proper DTO
  @Get('profile')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current user profile' })
  @ApiResponse({ status: 200, description: 'User profile retrieved successfully', type: UserResponseDto })
  async getProfile(@Request() req): Promise<UserResponseDto> {
    return this.usersService.getProfile(req.user.userId);
  }

  // ✅ NEW: Update profile
  @Put('profile')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update user profile' })
  @ApiResponse({ status: 200, description: 'Profile updated successfully', type: UserResponseDto })
  async updateProfile(
    @Request() req,
    @Body() updateProfileDto: UpdateProfileDto,
  ): Promise<UserResponseDto> {
    return this.usersService.updateProfile(req.user.userId, updateProfileDto);
  }

  // ✅ NEW: Delete account
  @Delete('profile')
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete user account' })
  @ApiResponse({ status: 200, description: 'Account deleted successfully' })
  async deleteAccount(@Request() req): Promise<{ message: string }> {
    await this.usersService.deleteAccount(req.user.userId);
    return { message: 'Account deleted successfully' };
  }

  // ✅ PRESERVED: Old endpoint for backward compatibility
  @Get(':id')
  @ApiOperation({ summary: 'Get user profile (legacy)' })
  async getUser(@Param('id') id: string) {
    const user = await this.usersService.findById(id);
    if (!user) {
      return { message: 'User not found' };
    }
    const { password, ...result } = user.toObject();
    return result;
  }

  // ✅ NEW: Enhanced public profile endpoint
  @Get('public/:id')
  @ApiOperation({ summary: 'Get public user profile' })
  @ApiResponse({ status: 200, description: 'Public profile retrieved successfully', type: PublicUserResponseDto })
  async getPublicProfile(@Param('id') id: string): Promise<PublicUserResponseDto> {
    return this.usersService.getPublicProfile(id);
  }

  // ✅ NEW: Skills management
  @Post('skills')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Add skills to user profile' })
  @ApiResponse({ status: 200, description: 'Skills added successfully', type: UserResponseDto })
  async addSkills(
    @Request() req,
    @Body() addSkillsDto: AddSkillsDto,
  ): Promise<UserResponseDto> {
    return this.usersService.addSkills(req.user.userId, addSkillsDto.skills);
  }

  @Delete('skills')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Remove skills from user profile' })
  @ApiResponse({ status: 200, description: 'Skills removed successfully', type: UserResponseDto })
  async removeSkills(
    @Request() req,
    @Body() removeSkillsDto: RemoveSkillsDto,
  ): Promise<UserResponseDto> {
    return this.usersService.removeSkills(req.user.userId, removeSkillsDto.skills);
  }

  // ✅ NEW: Search and discovery
  @Get()
  @ApiOperation({ summary: 'Search and list users' })
  @ApiQuery({ name: 'query', required: false, type: String })
  @ApiQuery({ name: 'role', required: false, type: String })
  @ApiQuery({ name: 'skills', required: false, type: String })
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

  // ✅ NEW: Verification
  @Post('verify')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Request profile verification' })
  @ApiResponse({ status: 200, description: 'Verification request submitted' })
  async requestVerification(@Request() req): Promise<{ message: string }> {
    return this.usersService.requestVerification(req.user.userId);
  }
}