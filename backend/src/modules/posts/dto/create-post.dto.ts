import { 
  IsString, 
  IsArray, 
  IsDate, 
  IsNumber, 
  IsEnum, 
  IsBoolean, 
  IsOptional, 
  IsMongoId,
  Min,
  MaxLength,
  ArrayMinSize
} from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreatePostDto {
  @ApiProperty({ description: 'Post title', maxLength: 200 })
  @IsString()
  @MaxLength(200)
  title: string;

  @ApiProperty({ description: 'Post description' })
  @IsString()
  description: string;

  @ApiProperty({ description: 'Requirements for the internship' })
  @IsArray()
  @IsString({ each: true })
  @ArrayMinSize(1)
  requirements: string[];

  @ApiProperty({ description: 'Skills required' })
  @IsArray()
  @IsString({ each: true })
  @ArrayMinSize(1)
  skillsRequired: string[];

  @ApiProperty({ description: 'Category of internship' })
  @IsString()
  category: string;

  @ApiPropertyOptional({ description: 'Team ID (optional - for existing teams)' })
  @IsOptional()
  @IsMongoId()
  team?: string; // CHANGED: Made optional

  @ApiProperty({ description: 'Application deadline' })
  @IsDate()
  @Type(() => Date)
  applicationDeadline: Date;

  @ApiProperty({ description: 'Internship duration' })
  @IsString()
  duration: string;

  @ApiProperty({ description: 'Commitment level', enum: ['full-time', 'part-time', 'contract'] })
  @IsEnum(['full-time', 'part-time', 'contract'])
  commitment: string;

  @ApiProperty({ description: 'Location type', enum: ['remote', 'hybrid', 'onsite'] })
  @IsEnum(['remote', 'hybrid', 'onsite'])
  location: string;

  @ApiPropertyOptional({ description: 'Stipend amount' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  stipend?: number;

  @ApiProperty({ description: 'Number of positions available', minimum: 1 })
  @IsNumber()
  @Min(1)
  positions: number;

  @ApiPropertyOptional({ description: 'Tags for searchability' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];

  @ApiPropertyOptional({ description: 'Whether post is public' })
  @IsOptional()
  @IsBoolean()
  isPublic?: boolean;
}