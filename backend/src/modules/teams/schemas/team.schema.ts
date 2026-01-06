// team.schema.ts (updated)
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';
import { User } from '../../users/schemas/user.schema';

export type TeamDocument = Team & Document;

@Schema({ timestamps: true })
export class Team {
  @Prop({ required: true, trim: true, maxlength: 50 })
  name: string;

  @Prop({ trim: true, maxlength: 500 })
  description: string;

  @Prop()
  logoUrl: string;

  @Prop({ type: [{ type: String }], default: [] })
  skills: string[];

  @Prop({
    type: [
      {
        user: { type: Types.ObjectId, ref: 'User', required: true },
        joinedAt: { type: Date, default: Date.now },
      },
    ],
    default: []
  })
  members: Array<{
    user: Types.ObjectId | User;
    joinedAt: Date;
  }>;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  owner: Types.ObjectId | User;

  @Prop({ default: Date.now })
  lastActivity: Date;

  // ADD THIS: Maximum members limit
  @Prop({ default: 4, min: 2, max: 10 })
  maxMembers: number;

  // ADD THIS: Team visibility
  @Prop({ default: 'public', enum: ['public', 'private'] })
  visibility: string;
  creatorId: any;
  createdBy: any;
}

export const TeamSchema = SchemaFactory.createForClass(Team);

// Indexes for better performance
TeamSchema.index({ 'members.user': 1 });
TeamSchema.index({ lastActivity: -1 });
TeamSchema.index({ owner: 1 });
TeamSchema.index({ visibility: 1 });