import { Role } from '../../../auth/enums/role.enum';
export declare class UserResponseDto {
    _id: string;
    email: string;
    name: string;
    skills: string[];
    bio: string;
    education: string;
    avatar: string;
    role: Role;
    isVerified: boolean;
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
export declare class PublicUserResponseDto {
    _id: string;
    name: string;
    role: Role;
    bio: string;
    skills: string[];
    avatar: string;
    isVerified: boolean;
    company: string;
    position: string;
    experienceYears: number;
}
export declare class PrivateUserResponseDto extends UserResponseDto {
}
