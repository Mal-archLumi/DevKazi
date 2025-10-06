
import { IsEmail, IsString, IsArray, MinLength, MaxLength, IsOptional, IsInt, Min, IsBoolean, IsUrl } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({ example: 'user@example.com', description: 'User email address' })
  @IsEmail({}, { message: 'Invalid email format' })
  email: string;

  @ApiProperty({ example: 'John Doe', description: 'User full name' })
  @IsString()
  @MinLength(2, { message: 'Name must be at least 2 characters long' })
  @MaxLength(50, { message: 'Name cannot exceed 50 characters' })
  name: string;

  @ApiProperty({ example: 'Password123!', description: 'User password (minimum 8 characters)' })
  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters long' })
  password: string;

  @ApiProperty({ example: ['student'], description: 'User roles', required: false })
  @IsOptional()
  @IsArray()
  @IsString({ each: true, message: 'Each role must be a string' })
  roles?: string[];

  @ApiProperty({ example: ['JavaScript', 'React'], description: 'User skills', required: false })
  @IsOptional()
  @IsArray()
  @IsString({ each: true, message: 'Each skill must be a string' })
  skills?: string[];

  @ApiProperty({ example: 'Full-stack developer with 3 years of experience', description: 'User bio', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(500, { message: 'Bio cannot exceed 500 characters' })
  bio?: string;

  @ApiProperty({ example: 'Computer Science Degree', description: 'User education', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(100, { message: 'Education cannot exceed 100 characters' })
  education?: string;

  @ApiProperty({ example: 'https://github.com/user', description: 'GitHub profile URL', required: false })
  @IsOptional()
  @IsUrl({}, { message: 'Invalid GitHub URL' })
  github?: string;

  @ApiProperty({ example: 'https://linkedin.com/in/user', description: 'LinkedIn profile URL', required: false })
  @IsOptional()
  @IsUrl({}, { message: 'Invalid LinkedIn URL' })
  linkedin?: string;

  @ApiProperty({ example: 'Tech Corp', description: 'User company', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(100, { message: 'Company name cannot exceed 100 characters' })
  company?: string;

  @ApiProperty({ example: 'Senior Developer', description: 'User position', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(100, { message: 'Position cannot exceed 100 characters' })
  position?: string;

  @ApiProperty({ example: 3, description: 'Years of experience', required: false })
  @IsOptional()
  @IsInt()
  @Min(0, { message: 'Experience years cannot be negative' })
  experienceYears?: number;

  @ApiProperty({ example: true, description: 'Whether profile is public', required: false })
  @IsOptional()
  @IsBoolean()
  isProfilePublic?: boolean;

  @ApiProperty({ example: true, description: 'Whether user is active', required: false })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
