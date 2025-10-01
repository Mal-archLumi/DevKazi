import { IsEmail, IsString, IsOptional, IsArray } from 'class-validator';

export class InviteMemberDto {
  @IsEmail()
  @IsOptional()
  email?: string;

  @IsString()
  @IsOptional()
  userId?: string;

  @IsString()
  @IsOptional()
  message?: string;
}

export class BulkInviteDto {
  @IsArray()
  emails: string[];

  @IsString()
  @IsOptional()
  message?: string;
}