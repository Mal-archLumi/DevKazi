import { PartialType } from '@nestjs/mapped-types';
import { CreateTeamDto } from './create-team.dto';
import { IsArray, IsOptional, IsEnum } from 'class-validator';
import { TeamStatus } from '../../teams/schemas/team.schema';

export class UpdateTeamDto extends PartialType(CreateTeamDto) {
  @IsOptional()
  @IsEnum(TeamStatus)
  status?: TeamStatus;

  @IsArray()
  @IsOptional()
  members?: Array<{
    user: string;
    role: string;
  }>;
}