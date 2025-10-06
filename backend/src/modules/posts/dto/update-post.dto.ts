import { PartialType } from '@nestjs/swagger';
import { CreatePostDto } from './create-post.dto';
import { IsEnum, IsOptional, IsDate, Min, IsNumber } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdatePostDto extends PartialType(CreatePostDto) {
  @ApiPropertyOptional({ 
    description: 'Post status', 
    enum: ['active', 'closed', 'draft'] 
  })
  @IsOptional()
  @IsEnum(['active', 'closed', 'draft'])
  status?: string;

  @ApiPropertyOptional({ description: 'Application deadline' })
  @IsOptional()
  @IsDate()
  @Type(() => Date)
  applicationDeadline?: Date;

  @ApiPropertyOptional({ description: 'Number of positions available', minimum: 1 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  positions?: number;

  @ApiPropertyOptional({ description: 'Stipend amount', minimum: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  stipend?: number;
}