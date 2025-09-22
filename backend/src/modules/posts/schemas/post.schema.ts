import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type RoleRequirement = {
  role: string;
  slots: number;
  skills: string[];
  filled: number;
};

@Schema({ timestamps: true })
export class Post extends Document {
  @Prop({ required: true })
  title: string;

  @Prop()
  description: string;

  @Prop({ type: Types.ObjectId, ref: 'Team', required: true })
  team: Types.ObjectId;

  @Prop({ type: String, enum: ['internship', 'team-formation'], required: true })
  type: string;

  @Prop([{
    role: String,
    slots: Number,
    skills: [String],
    filled: { type: Number, default: 0 }
  }])
  roles: RoleRequirement[];

  @Prop([String])
  requiredSkills: string[];

  @Prop()
  duration: string;

  @Prop()
  deadline: Date;

  @Prop({ default: 'active' })
  status: string;

  @Prop()
  companyLogo?: string;

  @Prop()
  projectName: string;

  @Prop({ default: 0 })
  applicationsCount: number;
}

export const PostSchema = SchemaFactory.createForClass(Post);