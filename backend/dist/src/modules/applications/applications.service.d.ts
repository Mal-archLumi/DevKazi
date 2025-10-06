import { Model } from 'mongoose';
import { ApplicationDocument } from './schemas/application.schema';
import { CreateApplicationDto } from './dto/create-application.dto';
import { ApplicationStatusDto } from './dto/application-status.dto';
import { PostsService } from '../posts/posts.service';
import { TeamsService } from '../teams/teams.service';
import { ApplicationResponseDto } from './dto/application-response.dto';
export declare class ApplicationsService {
    private applicationModel;
    private postsService;
    private teamsService;
    constructor(applicationModel: Model<ApplicationDocument>, postsService: PostsService, teamsService: TeamsService);
    create(createApplicationDto: CreateApplicationDto, userId: string): Promise<ApplicationResponseDto>;
    getUserApplications(userId: string): Promise<ApplicationResponseDto[]>;
    getTeamApplications(teamId: string, userId: string): Promise<ApplicationResponseDto[]>;
    updateStatus(applicationId: string, statusDto: ApplicationStatusDto, userId: string): Promise<ApplicationResponseDto>;
    getApplicationStats(teamId: string, userId: string): Promise<{
        [key: string]: number;
    }>;
    getApplicationAnalytics(teamId: string, userId: string): Promise<any>;
    withdrawApplication(applicationId: string, userId: string): Promise<ApplicationResponseDto>;
    private validatePostForApplication;
    private validateStatusTransition;
    private mapToResponseDto;
}
