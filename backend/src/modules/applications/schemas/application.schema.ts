import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';
import { ApiProperty } from '@nestjs/swagger';

export type ApplicationDocument = Application & Document;

@Schema({ timestamps: true, versionKey: false })
export class Application {
  @ApiProperty({ description: 'Application ID' })
  _id: Types.ObjectId;

  @ApiProperty({ description: 'Post being applied to' })
  @Prop({ type: Types.ObjectId, ref: 'Post', required: true, index: true })
  post: Types.ObjectId;

  @ApiProperty({ description: 'Applicant user' })
  @Prop({ type: Types.ObjectId, ref: 'User', required: true, index: true })
  applicant: Types.ObjectId;

  @ApiProperty({ description: 'Team receiving the application' })
  @Prop({ type: Types.ObjectId, ref: 'Team', required: true, index: true })
  team: Types.ObjectId;

  @ApiProperty({ description: 'Cover letter' })
  @Prop({ required: true, trim: true })
  coverLetter: string;

  @ApiProperty({ description: 'Resume URL', required: false })
  @Prop()
  resume?: string;

  @ApiProperty({ description: 'Applicant skills' })
  @Prop({ type: [String], default: [] })
  skills: string[];

  @ApiProperty({ description: 'Applicant experience' })
  @Prop({ trim: true })
  experience: string;

  @ApiProperty({ description: 'Application status' })
  @Prop({
    enum: ['pending', 'accepted', 'rejected', 'withdrawn'],
    default: 'pending'
  })
  status: string;

  @ApiProperty({ description: 'When application was submitted' })
  @Prop({ default: Date.now })
  appliedAt: Date;

  @ApiProperty({ description: 'When application was reviewed', required: false })
  @Prop()
  reviewedAt?: Date;

  @ApiProperty({ description: 'Who reviewed the application', required: false })
  @Prop({ type: Types.ObjectId, ref: 'User' })
  reviewedBy?: Types.ObjectId;

  @ApiProperty({ description: 'Internal notes', required: false })
  @Prop({ trim: true })
  notes?: string;
}

export const ApplicationSchema = SchemaFactory.createForClass(Application);

// Compound indexes for better query performance
ApplicationSchema.index({ post: 1, applicant: 1 }, { unique: true });
ApplicationSchema.index({ team: 1, status: 1 });
ApplicationSchema.index({ applicant: 1, status: 1 });