import { TeamsService } from './teams.service';
export declare class TeamsController {
    private readonly teamsService;
    constructor(teamsService: TeamsService);
    create(createTeamDto: any): Promise<import("./schemas/team.schema").Team>;
    findAll(): Promise<import("./schemas/team.schema").Team[]>;
    findBySkills(skills: string): Promise<import("./schemas/team.schema").Team[]>;
    findOne(id: string): Promise<import("./schemas/team.schema").Team>;
    update(id: string, updateTeamDto: any): Promise<import("./schemas/team.schema").Team>;
    addMember(id: string, memberData: any): Promise<import("./schemas/team.schema").Team>;
}
