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
}

export const MessageSchema = SchemaFactory.createForClass(Message);

// Index for better query performance
MessageSchema.index({ team: 1, timestamp: 1 });