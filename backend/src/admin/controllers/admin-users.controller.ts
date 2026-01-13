// admin/controllers/admin-users.controller.ts
import { 
  Controller, Get, Post, Put, Delete, Param, Body, Query, UseGuards, 
  ParseIntPipe, DefaultValuePipe, BadRequestException 
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../../modules/users/schemas/user.schema';
import { AdminUsersService } from '../services/admin-users.service';

@ApiTags('Admin - Users')
@ApiBearerAuth()
@Controller('admin/users')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
export class AdminUsersController {
  constructor(private readonly adminUsersService: AdminUsersService) {}

  @Get()
  @ApiOperation({ summary: 'Get all users (paginated)' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'search', required: false, type: String })
  @ApiQuery({ name: 'role', required: false, enum: UserRole })
  @ApiQuery({ name: 'isActive', required: false, type: Boolean })
  async getUsers(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number = 1,
    @Query('limit', new DefaultValuePipe(20), ParseIntPipe) limit: number = 20,
    @Query('search') search?: string,
    @Query('role') role?: UserRole,
    @Query('isActive') isActive?: boolean,
  ) {
    // Ensure limit is reasonable
    if (limit > 100) limit = 100;
    
    return this.adminUsersService.getUsers({
      page,
      limit,
      search,
      role,
      isActive: isActive !== undefined ? Boolean(isActive) : undefined,
    });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get user details by ID' })
  @ApiResponse({ status: 200, description: 'User details retrieved' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async getUserById(@Param('id') id: string) {
    return this.adminUsersService.getUserById(id);
  }

  @Put(':id/role')
  @ApiOperation({ summary: 'Update user role' })
  @ApiResponse({ status: 200, description: 'User role updated' })
  @ApiResponse({ status: 400, description: 'Invalid role' })
  async updateUserRole(
    @Param('id') id: string,
    @Body('role') role: UserRole,
  ) {
    if (!role) {
      throw new BadRequestException('Role is required');
    }
    
    if (!Object.values(UserRole).includes(role)) {
      throw new BadRequestException(`Invalid role. Must be one of: ${Object.values(UserRole).join(', ')}`);
    }
    
    return this.adminUsersService.updateUserRole(id, role);
  }

  @Put(':id/status')
  @ApiOperation({ summary: 'Update user active status' })
  async updateUserStatus(
    @Param('id') id: string,
    @Body('isActive') isActive: boolean,
  ) {
    return this.adminUsersService.updateUserStatus(id, isActive);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Deactivate user account (soft delete)' })
  async deactivateUser(@Param('id') id: string) {
    return this.adminUsersService.deactivateUser(id);
  }

  @Get(':id/stats')
  @ApiOperation({ summary: 'Get user statistics' })
  async getUserStats(@Param('id') id: string) {
    return this.adminUsersService.getUserStats(id);
  }
}