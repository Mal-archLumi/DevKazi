import { IsOptional, IsString, IsEnum, IsNumber, Min, Max, IsArray, IsBoolean } from 'class-validator';
import { Role } from '../../../auth/enums/role.enum';
import { Transform } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class SearchUsersDto {
  @ApiProperty({
    required: false,
    description: 'Search query for name, bio, education, or skills',
    example: 'JavaScript'
  })
  @IsOptional()
  @IsString()
  query?: string;

  @ApiProperty({
    required: false,
    enum: Role,
    description: 'Filter by user role',
    example: Role.MENTOR
  })
  @IsOptional()
  @IsEnum(Role)
  role?: Role;

  @ApiProperty({
    required: false,
    description: 'Filter by skills (comma-separated)',
    example: 'JavaScript,React,Node.js',
    type: [String]
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @Transform(({ value }) => {
    if (typeof value === 'string') {
      return value.split(',').map(skill => skill.trim()).filter(skill => skill.length > 0);
    }
    if (Array.isArray(value)) {
      return value.filter(skill => typeof skill === 'string' && skill.length > 0);
    }
    return [];
  })
  skills?: string[];

  @ApiProperty({
    required: false,
    description: 'Show only verified users',
    example: false,
    default: false
  })
  @IsOptional()
  @IsBoolean()
  @Transform(({ value }) => {
    if (value === 'true') return true;
    if (value === 'false') return false;
    return Boolean(value);
  })
  verifiedOnly?: boolean = false;

  @ApiProperty({
    required: false,
    description: 'Page number for pagination',
    example: 1,
    default: 1
  })
  @IsOptional()
  @IsNumber()
  @Transform(({ value }) => {
    const num = parseInt(value, 10);
    return isNaN(num) || num < 1 ? 1 : num;
  })
  @Min(1)
  page: number = 1;

  @ApiProperty({
    required: false,
    description: 'Number of items per page',
    example: 10,
    default: 10,
    maximum: 100
  })
  @IsOptional()
  @IsNumber()
  @Transform(({ value }) => {
    const num = parseInt(value, 10);
    if (isNaN(num) || num < 1) return 10;
    return Math.min(num, 100); // Enforce maximum limit of 100
  })
  @Min(1)
  @Max(100)
  limit: number = 10;
}