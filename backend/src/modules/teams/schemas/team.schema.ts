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

  @Prop({ required: true, unique: true })
  inviteCode: string;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  owner: Types.ObjectId | User;

  @Prop({ default: Date.now })
  lastActivity: Date;
}

export const TeamSchema = SchemaFactory.createForClass(Team);

// Indexes for better performance
TeamSchema.index({ inviteCode: 1 }, { unique: true });
TeamSchema.index({ 'members.user': 1 });
TeamSchema.index({ lastActivity: -1 });
TeamSchema.index({ owner: 1 });