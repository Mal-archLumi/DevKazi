import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Team } from './schemas/team.schema';

@Injectable()
export class TeamsService {
  constructor(@InjectModel(Team.name) private teamModel: Model<Team>) {}

  async create(createTeamDto: any): Promise<Team> {
    const team = new this.teamModel(createTeamDto);
    return team.save();
  }

  async findAll(): Promise<Team[]> {
    return this.teamModel.find().populate('owner', 'name email').populate('members.userId', 'name email');
  }

  async findById(id: string): Promise<Team> {
    const team = await this.teamModel.findById(id)
      .populate('owner', 'name email')
      .populate('members.userId', 'name email skills');
    if (!team) {
      throw new NotFoundException('Team not found');
    }
    return team;
  }

  async update(id: string, updateTeamDto: any): Promise<Team> {
    const team = await this.teamModel.findByIdAndUpdate(id, updateTeamDto, { new: true });
    if (!team) {
      throw new NotFoundException('Team not found');
    }
    return team;
  }

  async addMember(teamId: string, memberData: any): Promise<Team> {
    return this.teamModel.findByIdAndUpdate(
      teamId,
      { $push: { members: memberData } },
      { new: true }
    );
  }

  async findBySkills(skills: string[]): Promise<Team[]> {
    return this.teamModel.find({
      'requiredRoles.skills': { $in: skills },
      status: 'active'
    }).populate('owner', 'name email');
  }
}