// join-request-response.dto.ts
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Types } from 'mongoose';
import { JoinRequestStatus } from '../schemas/join-request.schema';

export class UserInfoDto {
  @ApiProperty({ type: String })
  id: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  email: string;

  @ApiPropertyOptional()
  avatar?: string;

  @ApiProperty({ type: [String] })
  skills?: string[];
}

export class TeamInfoDto {
  @ApiProperty({ type: String })
  id: string;

  @ApiProperty()
  name: string;

  @ApiPropertyOptional()
  description?: string;
}

export class JoinRequestResponseDto {
  @ApiProperty({ type: String })
  id: string;

  @ApiProperty({ type: String })
  teamId: string;

  @ApiProperty({ type: String })
  userId: string;

  @ApiProperty({ enum: JoinRequestStatus })
  status: string;

  @ApiPropertyOptional()
  message?: string;

  @ApiProperty()
  requestedAt: Date;

  @ApiPropertyOptional()
  handledAt?: Date;

  @ApiPropertyOptional({ type: String })
  handledBy?: string;

  @ApiPropertyOptional()
  responseMessage?: string;

  @ApiProperty({ type: UserInfoDto })
  user?: UserInfoDto;

  @ApiProperty({ type: TeamInfoDto })
  team?: TeamInfoDto;
}