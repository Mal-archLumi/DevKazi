import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Types } from 'mongoose';

class TeamMemberDto {
  @ApiProperty({ type: String })
  user: Types.ObjectId;

  @ApiProperty()
  name: string;

  @ApiProperty()
  email: string;

  @ApiProperty()
  joinedAt: Date;
}

export class TeamResponseDto {
  @ApiProperty({ type: String })
  _id: Types.ObjectId;

  @ApiProperty()
  name: string;

  @ApiPropertyOptional()
  description?: string;

  @ApiPropertyOptional()
  skills?: string[];

  @ApiProperty({ type: [TeamMemberDto] })
  members: TeamMemberDto[];

  @ApiProperty()
  inviteCode: string;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  lastActivity: Date;
}