import { IsEmail, IsString, IsOptional, IsArray, MinLength, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateUserDto {
  @ApiProperty({ example: 'user@example.com', description: 'User email address' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'John Doe', description: 'User full name' })
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  name: string;

  @ApiProperty({ example: 'Password123!', description: 'User password' })
  @IsString()
  @MinLength(6)
  password: string;

  @ApiProperty({ example: ['JavaScript', 'React'], description: 'User skills', required: false })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  skills?: string[];
}