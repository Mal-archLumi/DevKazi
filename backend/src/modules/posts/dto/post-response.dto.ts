import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Types } from 'mongoose';

export class TeamResponseDto {
  @ApiProperty({ type: String })
  _id: Types.ObjectId;

  @ApiProperty()
  name: string;

  @ApiPropertyOptional()
  avatar?: string;

  @ApiPropertyOptional()
  description?: string;
}

export class UserResponseDto {
  @ApiProperty({ type: String })
  _id: Types.ObjectId;

  @ApiProperty()
  name: string;

  @ApiPropertyOptional()
  avatar?: string;

  @ApiPropertyOptional()
  email?: string;
}

export class PostResponseDto {
  @ApiProperty({ type: String })
  _id: Types.ObjectId;

  @ApiProperty()
  title: string;

  @ApiProperty()
  description: string;

  @ApiProperty()
  requirements: string[];

  @ApiProperty()
  skillsRequired: string[];

  @ApiProperty()
  category: string;

  @ApiPropertyOptional({ type: TeamResponseDto })
  team?: TeamResponseDto;

  @ApiProperty({ type: UserResponseDto })
  createdBy: UserResponseDto;

  @ApiProperty()
  applicationDeadline: Date;

  @ApiProperty()
  duration: string;

  @ApiProperty()
  commitment: string;

  @ApiProperty()
  location: string;

  @ApiPropertyOptional()
  stipend?: number;

  @ApiProperty()
  positions: number;

  @ApiProperty()
  applicationsCount: number;

  @ApiProperty()
  status: string;

  @ApiProperty()
  tags: string[];

  @ApiProperty()
  isPublic: boolean;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;
}