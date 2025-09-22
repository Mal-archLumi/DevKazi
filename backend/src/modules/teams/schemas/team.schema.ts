import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type TeamMember = {
  userId: Types.ObjectId;
  role: string;
  joinedAt: Date;
};

export type RequiredRole = {
  role: string;
  slots: number;
  skills: string[];
  filled: number;
};

@Schema({ timestamps: true })
export class Team extends Document {
  @Prop({ required: true })
  name: string;

  @Prop()
  description: string;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  owner: Types.ObjectId;

  @Prop([{
    userId: { type: Types.ObjectId, ref: 'User' },
    role: String,
    joinedAt: Date
  }])
  members: TeamMember[];

  @Prop([{
    role: String,
    slots: Number,
    skills: [String],
    filled: { type: Number, default: 0 }
  }])
  requiredRoles: RequiredRole[];

  @Prop()
  projectName: string;

  @Prop()
  projectDescription: string;

  @Prop([String])
  techStack: string[];

  @Prop()
  duration: string;

  @Prop({ default: 'active' })
  status: string;

  @Prop()
  deadline: Date;
}

export const TeamSchema = SchemaFactory.createForClass(Team);