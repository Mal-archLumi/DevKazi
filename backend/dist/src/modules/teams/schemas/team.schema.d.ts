import { Document, Types } from 'mongoose';
import { User } from '../../users/schemas/user.schema';
export type TeamDocument = Team & Document;
export declare enum TeamRole {
    OWNER = "owner",
    ADMIN = "admin",
    MEMBER = "member"
}
export declare enum TeamStatus {
    ACTIVE = "active",
    INACTIVE = "inactive",
    ARCHIVED = "archived"
}
export declare class Team {
    name: string;
    description: string;
    projectIdea: string;
    requiredSkills: string[];
    preferredSkills: string[];
    maxMembers: number;
    members: Array<{
        user: Types.ObjectId | User;
        role: TeamRole;
        joinedAt: Date;
    }>;
    settings: {
        isPublic: boolean;
        allowJoinRequests: boolean;
        requireApproval: boolean;
    };
    pendingInvites: Types.ObjectId[];
    joinRequests: Array<{
        user: Types.ObjectId | User;
        message: string;
        createdAt: Date;
    }>;
    tags: string[];
    avatarUrl: string;
    status: TeamStatus;
    currentProjectCount: number;
    githubRepo: string;
    projectDemoUrl: string;
    completedProjects: number;
    successRate: number;
}
export declare const TeamSchema: import("mongoose").Schema<Team, import("mongoose").Model<Team, any, any, any, Document<unknown, any, Team, any, {}> & Team & {
    _id: Types.ObjectId;
} & {
    __v: number;
}, any>, {}, {}, {}, {}, import("mongoose").DefaultSchemaOptions, Team, Document<unknown, {}, import("mongoose").FlatRecord<Team>, {}, import("mongoose").ResolveSchemaOptions<import("mongoose").DefaultSchemaOptions>> & import("mongoose").FlatRecord<Team> & {
    _id: Types.ObjectId;
} & {
    __v: number;
}>;
