import { ApplicationsService } from './applications.service';
import { CreateApplicationDto } from './dto/create-application.dto';
import { ApplicationStatusDto } from './dto/application-status.dto';
import { ApplicationResponseDto } from './dto/application-response.dto';
export declare class ApplicationsController {
    private readonly applicationsService;
    constructor(applicationsService: ApplicationsService);
    create(createApplicationDto: CreateApplicationDto, req: any): Promise<ApplicationResponseDto>;
    getMyApplications(req: any): Promise<ApplicationResponseDto[]>;
    getTeamApplications(teamId: string, req: any): Promise<ApplicationResponseDto[]>;
    updateStatus(id: string, statusDto: ApplicationStatusDto, req: any): Promise<ApplicationResponseDto>;
    withdrawApplication(id: string, req: any): Promise<ApplicationResponseDto>;
    getApplicationStats(teamId: string, req: any): Promise<{
        [key: string]: number;
    }>;
    getApplicationAnalytics(teamId: string, req: any): Promise<any>;
}
