import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';
import { Role } from '../../../auth/enums/role.enum';

export type UserDocument = User & Document;

@Schema({ timestamps: true })
export class User extends Document {
  @Prop({ required: true, unique: true, lowercase: true, index: true })
  email: string;

  @Prop({ required: true, minlength: 8 })
  password: string;

  @Prop({ required: true, trim: true, minlength: 2, maxlength: 50 })
  name: string;

  @Prop({ type: [String], default: [] })
  skills: string[];

  @Prop({ trim: true, maxlength: 500 })
  bio: string;

  @Prop({ trim: true, maxlength: 200 })
  education: string;

  @Prop()
  avatar: string;

  @Prop({ type: [String], enum: Object.values(Role), default: [Role.STUDENT] })
  roles: string[];

  @Prop({ default: false })
  isVerified: boolean;

  @Prop({ default: true })
  isProfilePublic: boolean;

  @Prop({ trim: true, maxlength: 100 })
  company: string;

  @Prop({ trim: true, maxlength: 100 })
  position: string;

  @Prop({ match: /^https?:\/\/.+\..+$/ })
  github: string;

  @Prop({ match: /^https?:\/\/.+\..+$/ })
  linkedin: string;

  @Prop({ match: /^https?:\/\/.+\..+$/ })
  portfolio: string;

  @Prop({ min: 0, max: 50, default: 0 })
  experienceYears: number;

  @Prop({ default: true })
  isActive: boolean;

  // Explicitly define timestamps to ensure TypeScript knows about them
  createdAt: Date;
  updatedAt: Date;
}

export const UserSchema = SchemaFactory.createForClass(User);

// Add indexes for search optimization
UserSchema.index({ email: 1 });
UserSchema.index({ skills: 1 });
UserSchema.index({ name: 'text', bio: 'text', education: 'text' });
UserSchema.index({ roles: 1 });
UserSchema.index({ isActive: 1 });
UserSchema.index({ isVerified: 1 });
UserSchema.index({ isProfilePublic: 1 });