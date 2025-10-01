import { Document, Types } from 'mongoose';
export type RoleRequirement = {
    role: string;
    slots: number;
    skills: string[];
    filled: number;
};
export declare class Post extends Document {
    title: string;
    description: string;
    team: Types.ObjectId;
    type: string;
    roles: RoleRequirement[];
    requiredSkills: string[];
    duration: string;
    deadline: Date;
    status: string;
    companyLogo?: string;
    projectName: string;
    applicationsCount: number;
}
export declare const PostSchema: import("mongoose").Schema<Post, import("mongoose").Model<Post, any, any, any, Document<unknown, any, Post, any, {}> & Post & Required<{
    _id: unknown;
}> & {
    __v: number;
}, any>, {}, {}, {}, {}, import("mongoose").DefaultSchemaOptions, Post, Document<unknown, {}, import("mongoose").FlatRecord<Post>, {}, import("mongoose").ResolveSchemaOptions<import("mongoose").DefaultSchemaOptions>> & import("mongoose").FlatRecord<Post> & Required<{
    _id: unknown;
}> & {
    __v: number;
}>;
