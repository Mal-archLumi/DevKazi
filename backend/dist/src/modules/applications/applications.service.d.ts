import { Model } from 'mongoose';
import { Application } from './schemas/application.schema';
export declare class ApplicationsService {
    private applicationModel;
    constructor(applicationModel: Model<Application>);
    create(createApplicationDto: any): Promise<Application>;
    findByUser(userId: string): Promise<Application[]>;
    findByPost(postId: string): Promise<Application[]>;
    updateStatus(applicationId: string, status: string): Promise<Application>;
}
