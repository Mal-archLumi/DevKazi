// notifications.controller.ts
import {
  Controller,
  Get,
  Put,
  Delete,
  Param,
  Request,
  UseGuards,
  Query,
} from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { NotificationsService } from './notifications.service';

@ApiTags('notifications')
@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get()
  @ApiOperation({ summary: 'Get user notifications' })
  async getNotifications(@Request() req, @Query('limit') limit?: string) {
    const userId = req.user.userId || req.user.sub || req.user._id;
    return this.notificationsService.getUserNotifications(
      userId,
      limit ? parseInt(limit) : 50,
    );
  }

  @Get('unread-count')
  @ApiOperation({ summary: 'Get unread notification count' })
  async getUnreadCount(@Request() req) {
    const userId = req.user.userId || req.user.sub || req.user._id;
    const count = await this.notificationsService.getUnreadCount(userId);
    return { count };
  }

  @Put(':id/read')
  @ApiOperation({ summary: 'Mark notification as read' })
  async markAsRead(@Request() req, @Param('id') id: string) {
    const userId = req.user.userId || req.user.sub || req.user._id;
    return this.notificationsService.markAsRead(id, userId);
  }

  @Put('read-all')
  @ApiOperation({ summary: 'Mark all notifications as read' })
  async markAllAsRead(@Request() req) {
    const userId = req.user.userId || req.user.sub || req.user._id;
    return this.notificationsService.markAllAsRead(userId);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete notification' })
  async deleteNotification(@Request() req, @Param('id') id: string) {
    const userId = req.user.userId || req.user.sub || req.user._id;
    return this.notificationsService.deleteNotification(id, userId);
  }

  @Delete()
  @ApiOperation({ summary: 'Clear all notifications' })
  async clearAll(@Request() req) {
    const userId = req.user.userId || req.user.sub || req.user._id;
    return this.notificationsService.clearAll(userId);
  }
}