import { PartialType } from '@nestjs/mapped-types';
import { CreateTeamDto } from './create-team.dto';
import { IsOptional, IsString } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateTeamDto extends PartialType(CreateTeamDto) {
  @ApiPropertyOptional({ example: 'new-invite-code', description: 'New invite code' })
  @IsOptional()
  @IsString()
  inviteCode?: string;
}