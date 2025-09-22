import { Document, Types } from 'mongoose';
export declare class Application extends Document {
    applicant: Types.ObjectId;
    post: Types.ObjectId;
    team?: Types.ObjectId;
    role: string;
    message: string;
    status: string;
    appliedAs: string;
}
export declare const ApplicationSchema: import("mongoose").Schema<Application, import("mongoose").Model<Application, any, any, any, Document<unknown, any, Application, any, {}> & Application & Required<{
    _id: unknown;
}> & {
    __v: number;
}, any>, {}, {}, {}, {}, import("mongoose").DefaultSchemaOptions, Application, Document<unknown, {}, import("mongoose").FlatRecord<Application>, {}, import("mongoose").ResolveSchemaOptions<import("mongoose").DefaultSchemaOptions>> & import("mongoose").FlatRecord<Application> & Required<{
    _id: unknown;
}> & {
    __v: number;
}>;
