import { Document, Types } from 'mongoose';
export type ApplicationDocument = Application & Document;
export declare class Application {
    _id: Types.ObjectId;
    post: Types.ObjectId;
    applicant: Types.ObjectId;
    team: Types.ObjectId;
    coverLetter: string;
    resume?: string;
    skills: string[];
    experience: string;
    status: string;
    appliedAt: Date;
    reviewedAt?: Date;
    reviewedBy?: Types.ObjectId;
    notes?: string;
}
export declare const ApplicationSchema: import("mongoose").Schema<Application, import("mongoose").Model<Application, any, any, any, Document<unknown, any, Application, any, {}> & Application & Required<{
    _id: Types.ObjectId;
}> & {
    __v: number;
}, any>, {}, {}, {}, {}, import("mongoose").DefaultSchemaOptions, Application, Document<unknown, {}, import("mongoose").FlatRecord<Application>, {}, import("mongoose").ResolveSchemaOptions<import("mongoose").DefaultSchemaOptions>> & import("mongoose").FlatRecord<Application> & Required<{
    _id: Types.ObjectId;
}> & {
    __v: number;
}>;
