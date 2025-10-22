import { Types } from 'mongoose';
declare class TeamMemberDto {
    user: Types.ObjectId;
    name: string;
    email: string;
    joinedAt: Date;
}
export declare class TeamResponseDto {
    _id: Types.ObjectId;
    name: string;
    description?: string;
    skills?: string[];
    members: TeamMemberDto[];
    inviteCode: string;
    createdAt: Date;
    lastActivity: Date;
}
export {};
