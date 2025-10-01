import { ApplicationsService } from './applications.service';
export declare class ApplicationsController {
    private readonly applicationsService;
    constructor(applicationsService: ApplicationsService);
    create(createApplicationDto: any, req: any): Promise<import("./schemas/application.schema").Application>;
    getMyApplications(req: any): Promise<import("./schemas/application.schema").Application[]>;
    getPostApplications(postId: string): Promise<import("./schemas/application.schema").Application[]>;
    updateStatus(id: string, status: string): Promise<import("./schemas/application.schema").Application>;
}
