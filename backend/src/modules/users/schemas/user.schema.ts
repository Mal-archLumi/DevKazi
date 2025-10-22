import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type UserDocument = User & Document;

@Schema({ timestamps: true })
export class User {
  @Prop({ required: true, unique: true, lowercase: true, index: true })
  email: string;

  @Prop({ minlength: 6 }) // Removed 'required: true' for OAuth support
  password?: string;

  @Prop({ required: true, trim: true, minlength: 2, maxlength: 50 })
  name: string;

  @Prop({ unique: true, sparse: true }) // Add googleId for OAuth
  googleId?: string;

  @Prop() // Add picture field for Google profile
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

  @Prop({ virtual: true })
  joinedTeams?: Array<{
    team: Types.ObjectId;
    joinedAt: Date;
  }>;

  createdAt: Date;
  updatedAt: Date;

  @Prop()
  resetPasswordToken?: string;

  @Prop()
  resetPasswordExpires?: Date;
}

export const UserSchema = SchemaFactory.createForClass(User);

// Indexes for optimization
UserSchema.index({ email: 1 });
UserSchema.index({ googleId: 1 }); // Added for OAuth lookups
UserSchema.index({ skills: 1 });
UserSchema.index({ name: 'text', bio: 'text' });
UserSchema.index({ isActive: 1 });
UserSchema.index({ isVerified: 1 });