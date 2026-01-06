// src/modules/projects/schemas/project.schema.ts (UPDATE IF NEEDED)
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

@Schema({ timestamps: true })
export class Project extends Document {
  @Prop({ required: true })
  name: string;

  @Prop()
  description: string;

  @Prop({ type: Types.ObjectId, ref: 'Team', required: true })
  teamId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  createdBy: Types.ObjectId;

  @Prop({
    type: [
      {
        user: { type: Types.ObjectId, ref: 'User', default: null },
        role: { type: String, required: true },
        tasks: { type: String, default: '' },
        assignedTo: { type: String, default: '' }, // ADD THIS FIELD
      },
    ],
    default: [],
  })
  assignments: Array<{
    user?: Types.ObjectId;
    role: string;
    tasks: string;
    assignedTo?: string;
  }>;

  @Prop({
    type: [
      {
        phase: { type: String, required: true },
        description: { type: String, default: '' },
        startDate: { type: Date, required: true },
        endDate: { type: Date, required: true },
        status: { 
          type: String, 
          enum: ['planned', 'in-progress', 'completed'],
          default: 'planned' 
        },
      },
    ],
    default: [],
  })
  timeline: Array<{
    phase: string;
    description: string;
    startDate: Date;
    endDate: Date;
    status: string;
  }>;

  @Prop({
    type: [
      {
        title: { type: String, required: true },
        url: { type: String, required: true },
        pinnedBy: { type: Types.ObjectId, ref: 'User', required: true },
        pinnedAt: { type: Date, default: Date.now },
      },
    ],
    default: [],
  })
  pinnedLinks: Array<{
    title: string;
    url: string;
    pinnedBy: Types.ObjectId;
    pinnedAt: Date;
  }>;

  @Prop({
    type: [
      {
        title: { type: String, required: true },
        description: { type: String, required: true },
        createdBy: { type: Types.ObjectId, ref: 'User', required: true },
        createdAt: { type: Date, default: Date.now },
        status: { 
          type: String, 
          enum: ['pending', 'approved', 'rejected'],
          default: 'pending' 
        },
        upvotes: [{ type: Types.ObjectId, ref: 'User' }],
        downvotes: [{ type: Types.ObjectId, ref: 'User' }],
      },
    ],
    default: [],
  })
  ideas: Array<{
    title: string;
    description: string;
    createdBy: Types.ObjectId;
    createdAt: Date;
    status: string;
    upvotes: Types.ObjectId[];
    downvotes: Types.ObjectId[];
  }>;

  @Prop({ default: Date.now })
  lastUpdated: Date;

  @Prop({ default: true })
  isActive: boolean;

  @Prop({ 
    type: String, 
    enum: ['active', 'inactive', 'completed', 'archived'],
    default: 'active' 
  })
  status: string;

  @Prop({ type: Number, min: 0, max: 1, default: 0 })
  progress: number;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;
}

export const ProjectSchema = SchemaFactory.createForClass(Project);