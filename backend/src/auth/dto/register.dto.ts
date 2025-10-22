import { IsEmail, IsString, IsArray, MinLength, MaxLength, IsOptional, Matches } from 'class-validator';
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

  @ApiProperty({ 
    example: 'SecurePass123!', 
    description: 'User password (minimum 8 characters with uppercase, lowercase, and number)' 
  })
  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters long' })
  @Matches(/(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])/, {
    message: 'Password must contain at least one lowercase letter, one uppercase letter, and one number'
  })
  password: string;

  @ApiProperty({ example: ['JavaScript', 'React'], description: 'User skills', required: false })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  skills?: string[];
}