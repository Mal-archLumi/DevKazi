import { Types } from 'mongoose';
export declare class UserResponseDto {
    _id: Types.ObjectId;
    email: string;
    name: string;
    skills: string[];
    bio?: string;
    education?: string;
    avatar?: string;
    isVerified: boolean;
    isProfilePublic: boolean;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
}
export declare class PublicUserResponseDto {
    _id: Types.ObjectId;
    name: string;
    skills: string[];
    bio?: string;
    avatar?: string;
    isVerified: boolean;
}
