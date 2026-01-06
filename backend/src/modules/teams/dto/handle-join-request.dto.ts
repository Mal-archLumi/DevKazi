// handle-join-request.dto.ts
import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsOptional, IsString } from 'class-validator';

export class HandleJoinRequestDto {
  @ApiProperty({ description: 'Whether to approve the request' })
  @IsBoolean()
  approved: boolean;

  @ApiProperty({ required: false, description: 'Optional message for the user' })
  @IsOptional()
  @IsString()
  message?: string;
}