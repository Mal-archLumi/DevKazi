import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export type PostDocument = Post & Document;

@Schema({ timestamps: true, versionKey: false })
export class Post {
  @ApiProperty({ description: 'Post ID' })
  _id: Types.ObjectId;

  @ApiProperty({ description: 'Post title' })
  @Prop({ required: true, trim: true, maxlength: 200 })
  title: string;

  @ApiProperty({ description: 'Post description' })
  @Prop({ required: true, trim: true })
  description: string;

  @ApiProperty({ description: 'Requirements for the internship' })
  @Prop({ type: [String], default: [] })
  requirements: string[];

  @ApiProperty({ description: 'Skills required' })
  @Prop({ type: [String], default: [] })
  skillsRequired: string[];

  @ApiProperty({ description: 'Category of internship' })
  @Prop({ required: true, trim: true })
  category: string;

  @ApiPropertyOptional({ description: 'Team that created the post (optional)' })
  @Prop({ type: Types.ObjectId, ref: 'Team', index: true }) // CHANGED: Removed required
  team?: Types.ObjectId; // CHANGED: Made optional

  @ApiProperty({ description: 'User who created the post' })
  @Prop({ type: Types.ObjectId, ref: 'User', required: true, index: true })
  createdBy: Types.ObjectId;

  @ApiProperty({ description: 'Application deadline' })
  @Prop({ required: true })
  applicationDeadline: Date;

  @ApiProperty({ description: 'Internship duration' })
  @Prop({ required: true })
  duration: string;

  @ApiProperty({ description: 'Commitment level' })
  @Prop({ required: true, enum: ['full-time', 'part-time', 'contract'] })
  commitment: string;

  @ApiProperty({ description: 'Location type' })
  @Prop({ required: true, enum: ['remote', 'hybrid', 'onsite'] })
  location: string;

  @ApiPropertyOptional({ description: 'Stipend amount' })
  @Prop({ min: 0 })
  stipend?: number;

  @ApiProperty({ description: 'Number of positions available' })
  @Prop({ required: true, min: 1, default: 1 })
  positions: number;

  @ApiProperty({ description: 'Number of applications received' })
  @Prop({ default: 0, min: 0 })
  applicationsCount: number;

  @ApiProperty({ description: 'Post status' })
  @Prop({ 
    enum: ['active', 'closed', 'draft'],
    default: 'active'
  })
  status: string;

  @ApiProperty({ description: 'Tags for searchability' })
  @Prop({ type: [String], default: [], index: true })
  tags: string[];

  @ApiProperty({ description: 'Whether post is public' })
  @Prop({ default: true })
  isPublic: boolean;

  @ApiProperty({ description: 'Created at timestamp' })
  createdAt: Date;

  @ApiProperty({ description: 'Updated at timestamp' })
  updatedAt: Date;
}

export const PostSchema = SchemaFactory.createForClass(Post);

// Compound indexes for better query performance
PostSchema.index({ team: 1, status: 1 });
PostSchema.index({ category: 1, status: 1 });
PostSchema.index({ applicationDeadline: 1 });
PostSchema.index({ tags: 1 });