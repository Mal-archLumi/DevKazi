import { IsString, IsOptional, IsArray, MinLength, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateTeamDto {
  @ApiProperty({ example: 'Awesome Project Team', description: 'Team name' })
  @IsString()
  @MinLength(2, { message: 'Team name must be at least 2 characters' })
  @MaxLength(50, { message: 'Team name cannot exceed 50 characters' })
  name: string;

  @ApiPropertyOptional({ example: 'We are building a cool app', description: 'Team description' })
  @IsOptional()
  @IsString()
  @MaxLength(500, { message: 'Description cannot exceed 500 characters' })
  description?: string;

  @ApiPropertyOptional({ example: ['javascript', 'react'], description: 'Team skills' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  skills?: string[];
}