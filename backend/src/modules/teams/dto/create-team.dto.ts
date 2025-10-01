import { IsString, IsArray, IsOptional, IsNumber, IsBoolean, IsUrl, Min, Max } from 'class-validator';
import { TeamRole } from '../../teams/schemas/team.schema';

export class CreateTeamDto {
  @IsString()
  name: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsString()
  @IsOptional()
  projectIdea?: string;

  @IsArray()
  @IsOptional()
  requiredSkills?: string[];

  @IsArray()
  @IsOptional()
  preferredSkills?: string[];

  @IsNumber()
  @Min(2)
  @Max(10)
  @IsOptional()
  maxMembers?: number;

  @IsBoolean()
  @IsOptional()
  isPublic?: boolean;

  @IsBoolean()
  @IsOptional()
  allowJoinRequests?: boolean;

  @IsBoolean()
  @IsOptional()
  requireApproval?: boolean;

  @IsArray()
  @IsOptional()
  tags?: string[];

  @IsUrl()
  @IsOptional()
  githubRepo?: string;

  @IsUrl()
  @IsOptional()
  projectDemoUrl?: string;
}