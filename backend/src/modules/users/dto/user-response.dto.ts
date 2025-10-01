import { Role } from '../../../auth/enums/role.enum';

export class UserResponseDto {
  _id: string;
  email: string;
  name: string;
  skills: string[];
  bio: string;
  education: string;
  avatar: string;
  role: Role;
  isVerified: boolean;
  
  // New Phase 2 fields
  isProfilePublic: boolean;
  company: string;
  position: string;
  github: string;
  linkedin: string;
  portfolio: string;
  experienceYears: number;
  createdAt: Date;
  updatedAt: Date;
}

export class PublicUserResponseDto {
  _id: string;
  name: string;
  role: Role;
  bio: string;
  skills: string[];
  avatar: string;
  isVerified: boolean;
  
  // New Phase 2 fields (public only)
  company: string;
  position: string;
  experienceYears: number;
}

// For internal use (extends the full response)
export class PrivateUserResponseDto extends UserResponseDto {}