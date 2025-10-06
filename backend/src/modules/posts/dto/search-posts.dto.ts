import { IsOptional, IsString, IsNumber, IsEnum, Min, IsArray } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class SearchPostsDto {
  @ApiPropertyOptional({ description: 'Search query' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ description: 'Category filter' })
  @IsOptional()
  @IsString()
  category?: string;

  @ApiPropertyOptional({ description: 'Skills filter' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  skills?: string[];

  @ApiPropertyOptional({ description: 'Location filter', enum: ['remote', 'hybrid', 'onsite'] })
  @IsOptional()
  @IsEnum(['remote', 'hybrid', 'onsite'])
  location?: string;

  @ApiPropertyOptional({ description: 'Commitment filter', enum: ['full-time', 'part-time', 'contract'] })
  @IsOptional()
  @IsEnum(['full-time', 'part-time', 'contract'])
  commitment?: string;

  @ApiPropertyOptional({ description: 'Minimum stipend' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  minStipend?: number;

  @ApiPropertyOptional({ description: 'Maximum stipend' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  maxStipend?: number;

  @ApiPropertyOptional({ description: 'Page number', default: 1 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Type(() => Number)
  page?: number = 1;

  @ApiPropertyOptional({ description: 'Items per page', default: 10 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Type(() => Number)
  limit?: number = 10;

  @ApiPropertyOptional({ description: 'Sort field', default: 'createdAt' })
  @IsOptional()
  @IsString()
  sortBy?: string = 'createdAt';

  @ApiPropertyOptional({ description: 'Sort order', enum: ['asc', 'desc'], default: 'desc' })
  @IsOptional()
  @IsEnum(['asc', 'desc'])
  sortOrder?: string = 'desc';
}