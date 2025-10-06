import { Document, Types } from 'mongoose';
export interface IPost extends Document {
    _id: Types.ObjectId;
    title: string;
    description: string;
    requirements: string[];
    skillsRequired: string[];
    category: string;
    team: Types.ObjectId;
    createdBy: Types.ObjectId;
    applicationDeadline: Date;
    duration: string;
    commitment: 'full-time' | 'part-time' | 'contract';
    location: 'remote' | 'hybrid' | 'onsite';
    stipend?: number;
    positions: number;
    applicationsCount: number;
    status: 'active' | 'closed' | 'draft';
    tags: string[];
    isPublic: boolean;
    createdAt: Date;
    updatedAt: Date;
}
export type PostStatus = 'active' | 'closed' | 'draft';
export type CommitmentType = 'full-time' | 'part-time' | 'contract';
export type LocationType = 'remote' | 'hybrid' | 'onsite';
