import { Document, Types } from 'mongoose';
export type UserDocument = User & Document;
export declare class User {
    email: string;
    password?: string;
    name: string;
    googleId?: string;
    picture?: string;
    skills: string[];
    bio?: string;
    education?: string;
    avatar?: string;
    isVerified: boolean;
    isProfilePublic: boolean;
    isActive: boolean;
    joinedTeams?: Array<{
        team: Types.ObjectId;
        joinedAt: Date;
    }>;
    createdAt: Date;
    updatedAt: Date;
    resetPasswordToken?: string;
    resetPasswordExpires?: Date;
}
export declare const UserSchema: import("mongoose").Schema<User, import("mongoose").Model<User, any, any, any, Document<unknown, any, User, any, {}> & User & {
    _id: Types.ObjectId;
} & {
    __v: number;
}, any>, {}, {}, {}, {}, import("mongoose").DefaultSchemaOptions, User, Document<unknown, {}, import("mongoose").FlatRecord<User>, {}, import("mongoose").ResolveSchemaOptions<import("mongoose").DefaultSchemaOptions>> & import("mongoose").FlatRecord<User> & {
    _id: Types.ObjectId;
} & {
    __v: number;
}>;
