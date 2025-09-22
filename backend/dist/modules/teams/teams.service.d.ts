import { Model } from 'mongoose';
import { Team } from './schemas/team.schema';
export declare class TeamsService {
    private teamModel;
    constructor(teamModel: Model<Team>);
    create(createTeamDto: any): Promise<Team>;
    findAll(): Promise<Team[]>;
    findById(id: string): Promise<Team>;
    update(id: string, updateTeamDto: any): Promise<Team>;
    addMember(teamId: string, memberData: any): Promise<Team>;
    findBySkills(skills: string[]): Promise<Team[]>;
}
