import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';
import { User } from '../../users/schemas/user.schema';

export type TeamDocument = Team & Document;

export enum TeamRole {
  OWNER = 'owner',
  ADMIN = 'admin',
  MEMBER = 'member',
}

export enum TeamStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  ARCHIVED = 'archived',
}

@Schema({ timestamps: true })
export class Team {
  @Prop({ required: true })
  name: string;

  @Prop()
  description: string;

  @Prop()
  projectIdea: string;

  @Prop({ type: [{ type: String }] })
  requiredSkills: string[];

  @Prop({ type: [{ type: String }] })
  preferredSkills: string[];

  @Prop({ default: 5 })
  maxMembers: number;

  @Prop({
    type: [
      {
        user: { type: Types.ObjectId, ref: 'User' },
        role: { type: String, enum: TeamRole, default: TeamRole.MEMBER },
        joinedAt: { type: Date, default: Date.now },
      },
    ],
  })
  members: Array<{
    user: Types.ObjectId | User;
    role: TeamRole;
    joinedAt: Date;
  }>;

  @Prop({
    type: {
      isPublic: { type: Boolean, default: true },
      allowJoinRequests: { type: Boolean, default: true },
      requireApproval: { type: Boolean, default: true },
    },
  })
  settings: {
    isPublic: boolean;
    allowJoinRequests: boolean;
    requireApproval: boolean;
  };

  @Prop({
    type: [{ type: Types.ObjectId, ref: 'User' }],
  })
  pendingInvites: Types.ObjectId[];

  @Prop({
    type: [
      {
        user: { type: Types.ObjectId, ref: 'User' },
        message: String,
        createdAt: { type: Date, default: Date.now },
      },
    ],
  })
  joinRequests: Array<{
    user: Types.ObjectId | User;
    message: string;
    createdAt: Date;
  }>;

  @Prop({ type: [{ type: String }] })
  tags: string[];

  @Prop()
  avatarUrl: string;

  @Prop({ default: TeamStatus.ACTIVE })
  status: TeamStatus;

  @Prop({ default: 0 })
  currentProjectCount: number;

  @Prop()
  githubRepo: string;

  @Prop()
  projectDemoUrl: string;

  @Prop()
  completedProjects: number;

  @Prop()
  successRate: number;
}

export const TeamSchema = SchemaFactory.createForClass(Team);

// Create indexes for better search performance
TeamSchema.index({ name: 'text', description: 'text', projectIdea: 'text' });
TeamSchema.index({ 'members.user': 1 });
TeamSchema.index({ requiredSkills: 1 });
TeamSchema.index({ status: 1 });
TeamSchema.index({ createdAt: -1 });