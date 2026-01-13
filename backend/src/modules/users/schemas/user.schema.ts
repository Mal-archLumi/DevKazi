// users/schemas/user.schema.ts - UPDATED
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';
import { Team } from '../../teams/schemas/team.schema';

export type UserDocument = User & Document;

export enum UserRole {
  USER = 'user',
  ADMIN = 'admin',
  SUPER_ADMIN = 'super_admin'
}

@Schema({ timestamps: true })
export class User {
  @Prop({ required: true, unique: true, lowercase: true, index: true })
  email: string;

  @Prop({ minlength: 6 })
  password?: string;

  @Prop({ required: true, trim: true, minlength: 2, maxlength: 50 })
  name: string;

  @Prop({ unique: true, sparse: true })
  googleId?: string;

  @Prop()
  picture?: string;

  @Prop({ type: [String], default: [] })
  skills: string[];

  @Prop({ trim: true, maxlength: 500 })
  bio?: string;

  @Prop({ trim: true, maxlength: 200 })
  education?: string;

  @Prop()
  avatar?: string;

  @Prop({ default: false })
  isVerified: boolean;

  @Prop({ default: true })
  isProfilePublic: boolean;

  @Prop({ default: true })
  isActive: boolean;

  // ADMIN FIELD - UPDATED
  @Prop({ 
    type: String, 
    enum: UserRole, 
    default: UserRole.USER,
    index: true 
  })
  role: UserRole;

  @Prop({ type: [String], default: [] })
  permissions: string[]; // Specific permissions like 'view_analytics', 'manage_users'

  createdAt: Date;
  updatedAt: Date;

  @Prop()
  resetPasswordToken?: string;

  @Prop()
  resetPasswordExpires?: Date;

  // Keep this for backward compatibility
  @Prop({ default: false, select: false })
  isAdmin?: boolean;
}

export const UserSchema = SchemaFactory.createForClass(User);

// Virtual for team count
UserSchema.virtual('teamCount', {
  ref: 'Team',
  localField: '_id',
  foreignField: 'members.user',
  count: true,
});

// Virtual for project count
UserSchema.virtual('projectCount', {
  ref: 'Project',
  localField: '_id',
  foreignField: 'owner',
  count: true,
});

// Ensure virtuals are included in toJSON and toObject
UserSchema.set('toJSON', { 
  virtuals: true,
  transform: (doc, ret) => {
    delete ret.password;
    delete ret.resetPasswordToken;
    delete ret.resetPasswordExpires;
    return ret;
  }
});

UserSchema.set('toObject', { 
  virtuals: true,
  transform: (doc, ret) => {
    delete ret.password;
    delete ret.resetPasswordToken;
    delete ret.resetPasswordExpires;
    return ret;
  }
});

// Indexes for optimization
UserSchema.index({ email: 1 });
UserSchema.index({ googleId: 1 });
UserSchema.index({ skills: 1 });
UserSchema.index({ name: 'text', bio: 'text' });
UserSchema.index({ isActive: 1 });
UserSchema.index({ isVerified: 1 });
UserSchema.index({ role: 1 }); // Index for role queries