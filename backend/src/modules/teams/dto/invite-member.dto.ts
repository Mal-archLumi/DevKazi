import { IsEmail, IsString, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class InviteMemberDto {
  @ApiProperty({ example: 'user@example.com', description: 'Email to invite' })
  @IsEmail()
  email: string;

  @ApiPropertyOptional({ example: 'Join our team!', description: 'Invitation message' })
  @IsOptional()
  @IsString()
  message?: string;
}