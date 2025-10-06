import { 
  IsString, 
  IsArray, 
  IsOptional, 
  IsMongoId, 
  ArrayMinSize,
  MinLength,
  MaxLength 
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateApplicationDto {
  @ApiProperty({ description: 'Post ID to apply to' })
  @IsMongoId()
  post: string;

  @ApiProperty({ description: 'Cover letter', minLength: 50, maxLength: 2000 })
  @IsString()
  @MinLength(50)
  @MaxLength(2000)
  coverLetter: string;

  @ApiPropertyOptional({ description: 'Resume URL' })
  @IsOptional()
  @IsString()
  resume?: string;

  @ApiProperty({ description: 'Applicant skills' })
  @IsArray()
  @IsString({ each: true })
  @ArrayMinSize(1)
  skills: string[];

  @ApiProperty({ description: 'Applicant experience', minLength: 10, maxLength: 1000 })
  @IsString()
  @MinLength(10)
  @MaxLength(1000)
  experience: string;
}