import { IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RefreshTokenDto {
  @ApiProperty({ description: 'Refresh token to get new access token' })
  @IsNotEmpty()
  @IsString()
  refresh_token: string; // Should match your auth service expectation
}