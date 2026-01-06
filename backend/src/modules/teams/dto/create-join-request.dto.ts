// create-join-request.dto.ts
import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateJoinRequestDto {
  @ApiProperty({ description: 'Team ID to join' })
  @IsNotEmpty()
  @IsString()
  teamId: string;

  @ApiProperty({ required: false, description: 'Optional message to team creator' })
  @IsOptional()
  @IsString()
  message?: string;
}