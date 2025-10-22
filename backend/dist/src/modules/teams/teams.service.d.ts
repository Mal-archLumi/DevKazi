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
    private generateInviteCode;
    private getUserId;
    private isUserOwner;
    private isUserMember;
    create(createTeamDto: CreateTeamDto, userId: string): Promise<Team>;
    findOne(id: string): Promise<Team>;
    update(id: string, updateTeamDto: UpdateTeamDto, userId: string): Promise<Team>;
    remove(id: string, userId: string): Promise<void>;
    inviteMember(teamId: string, inviteMemberDto: InviteMemberDto, inviterId: string): Promise<Team>;
    joinTeam(inviteCode: string, userId: string): Promise<Team>;
    removeMember(teamId: string, memberId: string, removerId: string): Promise<Team>;
    getUserTeams(userId: string): Promise<Team[]>;
    regenerateInviteCode(teamId: string, userId: string): Promise<Team>;
    verifyTeamMembership(teamId: string, userId: string): Promise<boolean>;
    getTeamById(teamId: string): Promise<TeamDocument>;
}
