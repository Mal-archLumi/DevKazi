// notifications/notifications.service.ts - SIMPLIFIED
import { BadRequestException, Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Notification, NotificationDocument, NotificationType } from './schemas/notification.schema';
import { CreateNotificationDto } from './dto/create-notification.dto';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    @InjectModel(Notification.name)
    private notificationModel: Model<NotificationDocument>,
    // REMOVED TeamsService - not needed
  ) {}

  // Create notification
  async createNotification(userId: string, createNotificationDto: CreateNotificationDto) {
    // Validate userId is a valid ObjectId
    if (!Types.ObjectId.isValid(userId)) {
      this.logger.error(`Invalid userId: ${userId}`);
      throw new BadRequestException('Invalid user ID');
    }

    // Prepare notification data with proper ObjectId conversion
    const notificationData: any = {
      userId: new Types.ObjectId(userId),
      type: createNotificationDto.type,
      title: createNotificationDto.title,
      message: createNotificationDto.message,
      isRead: false,
    };

    // Convert teamId if provided and valid
    if (createNotificationDto.teamId && Types.ObjectId.isValid(createNotificationDto.teamId)) {
      notificationData.teamId = new Types.ObjectId(createNotificationDto.teamId);
    }

    // Convert projectId if provided and valid
    if (createNotificationDto.projectId && Types.ObjectId.isValid(createNotificationDto.projectId)) {
      notificationData.projectId = new Types.ObjectId(createNotificationDto.projectId);
    }

    // Convert triggeredBy if provided and valid
    if (createNotificationDto.triggeredBy && Types.ObjectId.isValid(createNotificationDto.triggeredBy)) {
      notificationData.triggeredBy = new Types.ObjectId(createNotificationDto.triggeredBy);
    }

    // Add actionUrl if provided
    if (createNotificationDto.actionUrl) {
      notificationData.actionUrl = createNotificationDto.actionUrl;
    }

    const notification = new this.notificationModel(notificationData);
    await notification.save();
    this.logger.log(`✅ Notification created for user ${userId}: ${createNotificationDto.title}`);
    return notification;
  }

  // Get user's notifications
  async getUserNotifications(userId: string, limit = 50) {
    const notifications = await this.notificationModel
      .find({ userId: new Types.ObjectId(userId) })
      .populate('triggeredBy', 'name email picture')
      .populate('teamId', 'name')
      .populate('projectId', 'title')
      .sort({ createdAt: -1 })
      .limit(limit)
      .lean()
      .exec();

    return notifications.map(notification => ({
      ...notification,
      _id: notification._id.toString(),
      userId: notification.userId.toString(),
      teamId: notification.teamId ? {
        _id: notification.teamId._id.toString(),
        name: (notification.teamId as any).name,
      } : undefined,
      projectId: notification.projectId ? {
        _id: notification.projectId._id.toString(),
        title: (notification.projectId as any).title,
      } : undefined,
      triggeredBy: notification.triggeredBy ? {
        _id: notification.triggeredBy._id.toString(),
        name: (notification.triggeredBy as any).name,
        email: (notification.triggeredBy as any).email,
        picture: (notification.triggeredBy as any).picture,
      } : undefined,
    }));
  }

  // Mark notification as read
  async markAsRead(notificationId: string, userId: string) {
    const result = await this.notificationModel.findOneAndUpdate(
      { _id: new Types.ObjectId(notificationId), userId: new Types.ObjectId(userId) },
      { isRead: true },
      { new: true },
    ).lean();

    if (!result) return null;

    return {
      ...result,
      _id: result._id.toString(),
      userId: result.userId.toString(),
    };
  }

  // Mark all as read
  async markAllAsRead(userId: string) {
    await this.notificationModel.updateMany(
      { userId: new Types.ObjectId(userId), isRead: false },
      { isRead: true },
    );
    return { success: true };
  }

  // Delete notification
  async deleteNotification(notificationId: string, userId: string) {
    const result = await this.notificationModel.findOneAndDelete({
      _id: new Types.ObjectId(notificationId),
      userId: new Types.ObjectId(userId),
    });

    return result ? { success: true } : { success: false };
  }

  // Clear all notifications
  async clearAll(userId: string) {
    await this.notificationModel.deleteMany({
      userId: new Types.ObjectId(userId),
    });
    return { success: true };
  }

  // Get unread count
  async getUnreadCount(userId: string): Promise<number> {
    return this.notificationModel.countDocuments({
      userId: new Types.ObjectId(userId),
      isRead: false,
    });
  }

  // ============ HELPER METHODS ============

  // 1. Join request notification (to team owner)
  async createJoinRequestNotification(
    teamId: string,
    teamOwnerId: string,
    requesterId: string,
    requesterName: string,
    teamName: string,
  ) {
    // Validate all IDs before creating notification
    if (!Types.ObjectId.isValid(teamOwnerId)) {
      this.logger.error(`Invalid teamOwnerId: ${teamOwnerId}`);
      return;
    }
    
    if (!Types.ObjectId.isValid(requesterId)) {
      this.logger.error(`Invalid requesterId: ${requesterId}`);
      return;
    }
    
    try {
      return await this.createNotification(teamOwnerId, {
        type: NotificationType.JOIN_REQUEST,
        title: 'New Join Request',
        message: `${requesterName} wants to join ${teamName}`,
        teamId: teamId,
        triggeredBy: requesterId,
        actionUrl: `/teams/${teamId}/requests`,
      });
    } catch (error) {
      this.logger.error(`Failed to create join request notification: ${error.message}`);
      return null;
    }
  }

  // 2. Join request approved (to requester)
  async createJoinApprovedNotification(
    teamId: string,
    requesterId: string,
    teamName: string,
    approvedBy: string,
  ) {
    // Validate IDs
    if (!Types.ObjectId.isValid(requesterId)) {
      this.logger.error(`Invalid requesterId: ${requesterId}`);
      return;
    }
    
    try {
      return await this.createNotification(requesterId, {
        type: NotificationType.JOIN_REQUEST_APPROVED,
        title: 'Join Request Approved! 🎉',
        message: `You've been accepted to ${teamName}`,
        teamId: teamId,
        triggeredBy: approvedBy,
        actionUrl: `/teams/${teamId}`,
      });
    } catch (error) {
      this.logger.error(`Failed to create join approved notification: ${error.message}`);
      return null;
    }
  }

  // 3. Join request rejected (to requester)
  async createJoinRejectedNotification(
    teamId: string,
    requesterId: string,
    teamName: string,
    rejectedBy: string,
  ) {
    // Validate IDs
    if (!Types.ObjectId.isValid(requesterId)) {
      this.logger.error(`Invalid requesterId: ${requesterId}`);
      return;
    }
    
    try {
      return await this.createNotification(requesterId, {
        type: NotificationType.JOIN_REQUEST_REJECTED,
        title: 'Join Request Declined',
        message: `Your request to join ${teamName} was declined`,
        teamId: teamId,
        triggeredBy: rejectedBy,
      });
    } catch (error) {
      this.logger.error(`Failed to create join rejected notification: ${error.message}`);
      return null;
    }
  }

  // 4. Project created (to all team members)
  async createProjectCreatedNotification(
    projectId: string,
    projectTitle: string,
    teamId: string,
    teamMemberIds: string[],
    createdBy: string,
  ) {
    const notifications = teamMemberIds
      .filter(memberId => memberId !== createdBy)
      .map(memberId => ({
        userId: new Types.ObjectId(memberId),
        type: NotificationType.PROJECT_CREATED,
        title: 'New Project Created',
        message: `New project: ${projectTitle}`,
        teamId: new Types.ObjectId(teamId),
        projectId: new Types.ObjectId(projectId),
        triggeredBy: new Types.ObjectId(createdBy),
        actionUrl: `/projects/${projectId}`,
        isRead: false,
      }));

    if (notifications.length > 0) {
      await this.notificationModel.insertMany(notifications);
      this.logger.log(`✅ Project created notifications sent to ${notifications.length} members`);
    }
  }

  // 5. Project completed (to all team members)
  async createProjectCompletedNotification(
    projectId: string,
    projectTitle: string,
    teamId: string,
    teamMemberIds: string[],
    completedBy: string,
  ) {
    const notifications = teamMemberIds
      .filter(memberId => memberId !== completedBy)
      .map(memberId => ({
        userId: new Types.ObjectId(memberId),
        type: NotificationType.PROJECT_COMPLETED,
        title: 'Project Completed! 🎉',
        message: `${projectTitle} has been completed`,
        teamId: new Types.ObjectId(teamId),
        projectId: new Types.ObjectId(projectId),
        triggeredBy: new Types.ObjectId(completedBy),
        actionUrl: `/projects/${projectId}`,
        isRead: false,
      }));

    if (notifications.length > 0) {
      await this.notificationModel.insertMany(notifications);
      this.logger.log(`✅ Project completed notifications sent to ${notifications.length} members`);
    }
  }
}