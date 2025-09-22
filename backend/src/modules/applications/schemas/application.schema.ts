import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

@Schema({ timestamps: true })
export class Application extends Document {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  applicant: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Post', required: true })
  post: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Team' })
  team?: Types.ObjectId;

  @Prop({ required: true })
  role: string;

  @Prop()
  message: string;

  @Prop({ default: 'pending' })
  status: string;

  @Prop()
  appliedAs: string; // 'individual' or 'team'
}

export const ApplicationSchema = SchemaFactory.createForClass(Application);