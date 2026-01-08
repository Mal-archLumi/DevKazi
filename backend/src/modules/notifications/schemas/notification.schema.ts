// schemas/notification.schema.ts
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type NotificationDocument = Notification & Document;

export enum NotificationType {
  JOIN_REQUEST = 'join_request',           // Someone wants to join your team
  JOIN_REQUEST_APPROVED = 'join_approved',  // Your request was approved
  JOIN_REQUEST_REJECTED = 'join_rejected',  // Your request was rejected
  PROJECT_CREATED = 'project_created',      // New project in your team
  PROJECT_COMPLETED = 'project_completed',  // Project marked as complete
}

@Schema({ timestamps: true })
export class Notification {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  userId: Types.ObjectId; // Who receives this notification

  @Prop({ 
    type: String, 
    enum: Object.values(NotificationType), 
    required: true 
  })
  type: NotificationType;

  @Prop({ type: String, required: true })
  title: string;

  @Prop({ type: String, required: true })
  message: string;

  @Prop({ type: Types.ObjectId, ref: 'Team' })
  teamId?: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Project' })
  projectId?: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'User' })
  triggeredBy?: Types.ObjectId; // Who caused this notification

  @Prop({ type: Boolean, default: false })
  isRead: boolean;

  @Prop({ type: String }) // Optional: for navigation (e.g., "/teams/123")
  actionUrl?: string;
}

export const NotificationSchema = SchemaFactory.createForClass(Notification);

// Indexes
NotificationSchema.index({ userId: 1, isRead: 1 });
NotificationSchema.index({ userId: 1, createdAt: -1 });