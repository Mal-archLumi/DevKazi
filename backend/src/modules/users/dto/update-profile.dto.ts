import { IsEmail, IsOptional, IsString, IsArray, IsEnum, IsNumber, Min, Max, IsBoolean, IsUrl } from 'class-validator';
import { Role } from '../../../auth/enums/role.enum';

export class UpdateProfileDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsString()
  bio?: string;

  @IsOptional()
  @IsString()
  education?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  skills?: string[];

  // New Phase 2 fields
  @IsOptional()
  @IsString()
  company?: string;

  @IsOptional()
  @IsString()
  position?: string;

  @IsOptional()
  @IsUrl()
  github?: string;

  @IsOptional()
  @IsUrl()
  linkedin?: string;

  @IsOptional()
  @IsUrl()
  portfolio?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(50)
  experienceYears?: number;

  @IsOptional()
  @IsBoolean()
  isProfilePublic?: boolean;

  // Role update should be restricted to admins only
  @IsOptional()
  @IsEnum(Role)
  role?: Role;
}