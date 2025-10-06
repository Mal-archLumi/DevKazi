import { Types } from 'mongoose';
export declare class PostResponseDto {
    _id: Types.ObjectId;
    title: string;
    team?: any;
}
export declare class UserResponseDto {
    _id: Types.ObjectId;
    name: string;
    avatar?: string;
    email?: string;
}
export declare class TeamResponseDto {
    _id: Types.ObjectId;
    name: string;
    avatar?: string;
}
export declare class ApplicationResponseDto {
    _id: Types.ObjectId;
    post: PostResponseDto;
    applicant: UserResponseDto;
    team?: TeamResponseDto;
    coverLetter: string;
    resume?: string;
    skills: string[];
    experience: string;
    status: string;
    appliedAt: Date;
    reviewedAt?: Date;
    reviewedBy?: UserResponseDto;
    notes?: string;
    createdAt: Date;
    updatedAt: Date;
}
