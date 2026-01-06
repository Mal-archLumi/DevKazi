// src/modules/projects/dto/update-project.dto.ts
import { PartialType } from '@nestjs/swagger'; // Changed from '@nestjs/mapped-types'
import { CreateProjectDto } from './create-project.dto';
import { IsString, IsOptional, IsArray, ValidateNested, IsDateString, IsNumber, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';

export class UpdateProjectDto extends PartialType(CreateProjectDto) {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => AssignmentDto)
  assignments?: AssignmentDto[];

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => TimelinePhaseDto)
  timeline?: TimelinePhaseDto[];

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(100)
  progress?: number;

  @IsOptional()
  @IsString()
  status?: string;
}

// Assignment DTO - add assignedTo here
class AssignmentDto {
  @IsOptional()
  @IsString()
  userId?: string;

  @IsString()
  role: string;

  @IsString()
  tasks: string;

  @IsOptional()
  @IsString()
  assignedTo?: string;  // ADD THIS LINE
}

// Timeline DTO
class TimelinePhaseDto {
  @IsString()
  phase: string;

  @IsString()
  description: string;

  @IsDateString()
  startDate: string;

  @IsDateString()
  endDate: string;

  @IsOptional()
  @IsString()
  status?: string;
}