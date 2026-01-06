import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

@Schema({ timestamps: true })
export class Message extends Document {
  @Prop({ type: Types.ObjectId, ref: 'Team', required: true, index: true })
  team: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true, index: true })
  sender: Types.ObjectId;

  @Prop({ required: true, trim: true, maxlength: 1000 })
  content: string;

  @Prop({ default: Date.now })
  timestamp: Date;

  @Prop({ type: Types.ObjectId, ref: 'Message', required: false })
  replyTo?: Types.ObjectId;

  // Virtual for teamId
  get teamId(): string {
    return this.team.toString();
  }

  // Virtual for senderId
  get senderId(): string {
    return this.sender.toString();
  }
}

export const MessageSchema = SchemaFactory.createForClass(Message);

// Add virtuals to schema
MessageSchema.virtual('teamId').get(function() {
  return this.team.toString();
});

MessageSchema.virtual('senderId').get(function() {
  return this.sender.toString();
});

// Ensure virtuals are included in JSON
MessageSchema.set('toJSON', { 
  virtuals: true,
  transform: function(doc, ret) {
    ret.id = ret._id.toString();
    delete ret._id;
    delete ret.__v;
    return ret;
  }
});

MessageSchema.set('toObject', { virtuals: true });

// Index for better query performance
MessageSchema.index({ team: 1, timestamp: 1 });
