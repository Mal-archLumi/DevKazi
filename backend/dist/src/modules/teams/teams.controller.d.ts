import { TeamsService } from './teams.service';
import { CreateTeamDto } from './dto/create-team.dto';
import { UpdateTeamDto } from './dto/update-team.dto';
import { InviteMemberDto } from './dto/invite-member.dto';
export declare class TeamsController {
    private readonly teamsService;
    constructor(teamsService: TeamsService);
    create(createTeamDto: CreateTeamDto, req: any): Promise<import("./schemas/team.schema").Team>;
    getUserTeams(req: any): Promise<import("./schemas/team.schema").Team[]>;
    findOne(id: string): Promise<import("./schemas/team.schema").Team>;
    update(id: string, updateTeamDto: UpdateTeamDto, req: any): Promise<import("./schemas/team.schema").Team>;
    remove(id: string, req: any): Promise<void>;
    inviteMember(id: string, inviteMemberDto: InviteMemberDto, req: any): Promise<import("./schemas/team.schema").Team>;
    joinTeam(inviteCode: string, req: any): Promise<import("./schemas/team.schema").Team>;
    removeMember(id: string, memberId: string, req: any): Promise<import("./schemas/team.schema").Team>;
    regenerateInviteCode(id: string, req: any): Promise<import("./schemas/team.schema").Team>;
}
