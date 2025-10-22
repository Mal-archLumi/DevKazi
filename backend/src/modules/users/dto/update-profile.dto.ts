import { IsOptional, IsString, IsArray, IsBoolean } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateProfileDto {
  @ApiPropertyOptional({ example: 'Jane Doe', description: 'User full name' })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({ example: ['JavaScript', 'React'], description: 'User skills' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  skills?: string[];

  @ApiPropertyOptional({ example: 'I love coding!', description: 'User bio' })
  @IsOptional()
  @IsString()
  bio?: string;

  @ApiPropertyOptional({ example: 'Computer Science', description: 'User education' })
  @IsOptional()
  @IsString()
  education?: string;

  @ApiPropertyOptional({ example: true, description: 'Whether profile is public' })
  @IsOptional()
  @IsBoolean()
  isProfilePublic?: boolean;
}