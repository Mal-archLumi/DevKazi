import { Document, Types } from 'mongoose';
export interface IApplication extends Document {
    _id: Types.ObjectId;
    post: Types.ObjectId;
    applicant: Types.ObjectId;
    team: Types.ObjectId;
    coverLetter: string;
    resume?: string;
    skills: string[];
    experience: string;
    status: 'pending' | 'accepted' | 'rejected' | 'withdrawn';
    appliedAt: Date;
    reviewedAt?: Date;
    reviewedBy?: Types.ObjectId;
    notes?: string;
    createdAt: Date;
    updatedAt: Date;
}
export type ApplicationStatus = 'pending' | 'accepted' | 'rejected' | 'withdrawn';
