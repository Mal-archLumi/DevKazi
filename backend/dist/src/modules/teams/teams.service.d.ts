import { Model } from 'mongoose';
import { Team, TeamDocument } from './schemas/team.schema';
import { UserDocument } from '../users/schemas/user.schema';
import { CreateTeamDto } from './dto/create-team.dto';
import { UpdateTeamDto } from './dto/update-team.dto';
import { InviteMemberDto } from './dto/invite-member.dto';
export declare class TeamsService {
    private teamModel;
    private userModel;
    private readonly logger;
    constructor(teamModel: Model<TeamDocument>, userModel: Model<UserDocument>);
    private getUserId;
    private isUserOwnerOrAdmin;
    private isUserOwner;
    create(createTeamDto: CreateTeamDto, userId: string): Promise<Team>;
    findAll(page?: number, limit?: number, search?: string): Promise<{
        teams: Team[];
        total: number;
        page: number;
        totalPages: number;
    }>;
    findOne(id: string): Promise<Team>;
    update(id: string, updateTeamDto: UpdateTeamDto, userId: string): Promise<Team>;
    remove(id: string, userId: string): Promise<void>;
    inviteMember(teamId: string, inviteMemberDto: InviteMemberDto, inviterId: string): Promise<Team>;
    joinTeam(teamId: string, userId: string, message?: string): Promise<Team>;
    respondToJoinRequest(teamId: string, requestUserId: string, approverId: string, accept: boolean): Promise<Team>;
    removeMember(teamId: string, memberId: string, removerId: string): Promise<Team>;
    getUserTeams(userId: string): Promise<Team[]>;
    searchTeams(skills?: string[], search?: string, page?: number, limit?: number): Promise<{
        teams: Team[];
        total: number;
        page: number;
        totalPages: number;
    }>;
    verifyTeamMembership(teamId: string, userId: string): Promise<boolean>;
    getTeamById(teamId: string): Promise<TeamDocument>;
    verifyTeamAdmin(teamId: string, userId: string): Promise<boolean>;
}
