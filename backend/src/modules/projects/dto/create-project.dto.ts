// src/modules/projects/dto/create-project.dto.ts
import { 
  IsString, 
  IsOptional, 
  IsArray, 
  ValidateNested, 
  IsMongoId,
  IsDateString,
  IsEnum,
  IsNotEmpty 
} from 'class-validator';
import { Type, Transform } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class ProjectAssignmentDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  userId?: string;

  @ApiProperty({ 
    enum: ['frontend', 'backend', 'ui', 'fullstack', 'custom'] 
  })
  @IsString()
  @IsEnum(['frontend', 'backend', 'ui', 'fullstack', 'custom'])
  role: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  tasks?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  assignedTo?: string;
}

export class TimelinePhaseDto {
  @ApiProperty()
  @IsString()
  phase: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty()
  @IsDateString()
  startDate: string;

  @ApiProperty()
  @IsDateString()
  endDate: string;

  @ApiProperty({ 
    enum: ['planned', 'in-progress', 'completed'],
    default: 'planned'
  })
  @IsOptional()
  @IsString()
  @IsEnum(['planned', 'in-progress', 'completed'])
  status?: string;
}

export class CreateProjectDto {
  @ApiProperty()
  @IsString()
  name: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty()
  @IsMongoId()
  teamId: string;

  @ApiProperty({ type: [ProjectAssignmentDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ProjectAssignmentDto)
  assignments?: ProjectAssignmentDto[];

  @ApiProperty({ type: [TimelinePhaseDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => TimelinePhaseDto)
  timeline?: TimelinePhaseDto[];
}
