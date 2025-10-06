import { Document, Types } from 'mongoose';
export type PostDocument = Post & Document;
export declare class Post {
    _id: Types.ObjectId;
    title: string;
    description: string;
    requirements: string[];
    skillsRequired: string[];
    category: string;
    team?: Types.ObjectId;
    createdBy: Types.ObjectId;
    applicationDeadline: Date;
    duration: string;
    commitment: string;
    location: string;
    stipend?: number;
    positions: number;
    applicationsCount: number;
    status: string;
    tags: string[];
    isPublic: boolean;
    createdAt: Date;
    updatedAt: Date;
}
export declare const PostSchema: import("mongoose").Schema<Post, import("mongoose").Model<Post, any, any, any, Document<unknown, any, Post, any, {}> & Post & Required<{
    _id: Types.ObjectId;
}> & {
    __v: number;
}, any>, {}, {}, {}, {}, import("mongoose").DefaultSchemaOptions, Post, Document<unknown, {}, import("mongoose").FlatRecord<Post>, {}, import("mongoose").ResolveSchemaOptions<import("mongoose").DefaultSchemaOptions>> & import("mongoose").FlatRecord<Post> & Required<{
    _id: Types.ObjectId;
}> & {
    __v: number;
}>;
