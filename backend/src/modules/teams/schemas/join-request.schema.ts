// join-request.schema.ts
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type JoinRequestDocument = JoinRequest & Document;

export enum JoinRequestStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  CANCELLED = 'cancelled',
}

@Schema({ 
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
})
export class JoinRequest {
  @Prop({ type: Types.ObjectId, ref: 'Team', required: true })
  teamId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  userId: Types.ObjectId;

  @Prop({
    type: String,
    enum: Object.values(JoinRequestStatus),
    default: JoinRequestStatus.PENDING,
  })
  status: JoinRequestStatus;

  @Prop({ type: String })
  message?: string;

  @Prop({ type: Types.ObjectId, ref: 'User' })
  handledBy?: Types.ObjectId;

  @Prop({ type: Date })
  handledAt?: Date;

  @Prop({ type: String })
  responseMessage?: string;
}

export const JoinRequestSchema = SchemaFactory.createForClass(JoinRequest);

// Add virtual fields for cleaner API responses
JoinRequestSchema.virtual('team', {
  ref: 'Team',
  localField: 'teamId',
  foreignField: '_id',
  justOne: true,
});

JoinRequestSchema.virtual('user', {
  ref: 'User',
  localField: 'userId',
  foreignField: '_id',
  justOne: true,
});

// Indexes
JoinRequestSchema.index({ teamId: 1, status: 1 });
JoinRequestSchema.index({ userId: 1, status: 1 });
JoinRequestSchema.index({ teamId: 1, userId: 1 });