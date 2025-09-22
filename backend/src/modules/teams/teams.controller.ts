import { Controller, Get, Post, Body, Param, Put, UseGuards, Query } from '@nestjs/common';
import { TeamsService } from './teams.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@Controller('teams')
@UseGuards(JwtAuthGuard)
export class TeamsController {
  constructor(private readonly teamsService: TeamsService) {}

  @Post()
  async create(@Body() createTeamDto: any) {
    return this.teamsService.create(createTeamDto);
  }

  @Get()
  async findAll() {
    return this.teamsService.findAll();
  }

  @Get('search')
  async findBySkills(@Query('skills') skills: string) {
    const skillsArray = skills ? skills.split(',') : [];
    return this.teamsService.findBySkills(skillsArray);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.teamsService.findById(id);
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() updateTeamDto: any) {
    return this.teamsService.update(id, updateTeamDto);
  }

  @Post(':id/members')
  async addMember(@Param('id') id: string, @Body() memberData: any) {
    return this.teamsService.addMember(id, memberData);
  }
}