import { TeamsService } from './teams.service';
import { CreateTeamDto } from './dto/create-team.dto';
import { UpdateTeamDto } from './dto/update-team.dto';
import { InviteMemberDto } from './dto/invite-member.dto';
export declare class TeamsController {
    private readonly teamsService;
    constructor(teamsService: TeamsService);
    create(createTeamDto: CreateTeamDto, req: any): Promise<import("./schemas/team.schema").Team>;
    findAll(page: number, limit: number, search?: string): Promise<{
        teams: import("./schemas/team.schema").Team[];
        total: number;
        page: number;
        totalPages: number;
    }>;
    searchTeams(skills?: string, search?: string, page?: number, limit?: number): Promise<{
        teams: import("./schemas/team.schema").Team[];
        total: number;
        page: number;
        totalPages: number;
    }>;
    getUserTeams(req: any): Promise<import("./schemas/team.schema").Team[]>;
    findOne(id: string): Promise<import("./schemas/team.schema").Team>;
    update(id: string, updateTeamDto: UpdateTeamDto, req: any): Promise<import("./schemas/team.schema").Team>;
    remove(id: string, req: any): Promise<void>;
    inviteMember(id: string, inviteMemberDto: InviteMemberDto, req: any): Promise<import("./schemas/team.schema").Team>;
    joinTeam(id: string, req: any, body: {
        message?: string;
    }): Promise<import("./schemas/team.schema").Team>;
    respondToJoinRequest(id: string, userId: string, req: any, body: {
        accept: boolean;
    }): Promise<import("./schemas/team.schema").Team>;
    removeMember(id: string, memberId: string, req: any): Promise<import("./schemas/team.schema").Team>;
}
