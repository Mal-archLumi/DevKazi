import { Document, Types } from 'mongoose';
import { User } from '../../users/schemas/user.schema';
export type TeamDocument = Team & Document;
export declare class Team {
    name: string;
    description: string;
    skills: string[];
    members: Array<{
        user: Types.ObjectId | User;
        joinedAt: Date;
    }>;
    inviteCode: string;
    owner: Types.ObjectId | User;
    lastActivity: Date;
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
