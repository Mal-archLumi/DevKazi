import { Types } from 'mongoose';
export declare class TeamResponseDto {
    _id: Types.ObjectId;
    name: string;
    avatar?: string;
    description?: string;
}
export declare class UserResponseDto {
    _id: Types.ObjectId;
    name: string;
    avatar?: string;
    email?: string;
}
export declare class PostResponseDto {
    _id: Types.ObjectId;
    title: string;
    description: string;
    requirements: string[];
    skillsRequired: string[];
    category: string;
    team?: TeamResponseDto;
    createdBy: UserResponseDto;
    applicationDeadline: Date;
    duration: string;
    commitment: string;
    location: string;
    stipend?: number;
    positions: number;
    applicationsCount: number;
    status: string;
    tags: string[];
    isPublic: boolean;
    createdAt: Date;
    updatedAt: Date;
}
