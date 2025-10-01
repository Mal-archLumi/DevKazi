import { Document, Types } from 'mongoose';
export type TeamMember = {
    userId: Types.ObjectId;
    role: string;
    joinedAt: Date;
};
export type RequiredRole = {
    role: string;
    slots: number;
    skills: string[];
    filled: number;
};
export declare class Team extends Document {
    name: string;
    description: string;
    owner: Types.ObjectId;
    members: TeamMember[];
    requiredRoles: RequiredRole[];
    projectName: string;
    projectDescription: string;
    techStack: string[];
    duration: string;
    status: string;
    deadline: Date;
}
export declare const TeamSchema: import("mongoose").Schema<Team, import("mongoose").Model<Team, any, any, any, Document<unknown, any, Team, any, {}> & Team & Required<{
    _id: unknown;
}> & {
    __v: number;
}, any>, {}, {}, {}, {}, import("mongoose").DefaultSchemaOptions, Team, Document<unknown, {}, import("mongoose").FlatRecord<Team>, {}, import("mongoose").ResolveSchemaOptions<import("mongoose").DefaultSchemaOptions>> & import("mongoose").FlatRecord<Team> & Required<{
    _id: unknown;
}> & {
    __v: number;
}>;
