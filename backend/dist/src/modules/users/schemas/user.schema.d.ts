import { Document } from 'mongoose';
export type UserDocument = User & Document;
export declare class User extends Document {
    email: string;
    password: string;
    name: string;
    skills: string[];
    bio: string;
    education: string;
    avatar: string;
    roles: string[];
    isVerified: boolean;
    isProfilePublic: boolean;
    company: string;
    position: string;
    github: string;
    linkedin: string;
    portfolio: string;
    experienceYears: number;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
}
export declare const UserSchema: import("mongoose").Schema<User, import("mongoose").Model<User, any, any, any, Document<unknown, any, User, any, {}> & User & Required<{
    _id: unknown;
}> & {
    __v: number;
}, any>, {}, {}, {}, {}, import("mongoose").DefaultSchemaOptions, User, Document<unknown, {}, import("mongoose").FlatRecord<User>, {}, import("mongoose").ResolveSchemaOptions<import("mongoose").DefaultSchemaOptions>> & import("mongoose").FlatRecord<User> & Required<{
    _id: unknown;
}> & {
    __v: number;
}>;
