import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Types } from 'mongoose';

export class PostResponseDto {
  @ApiProperty({ type: String })
  _id: Types.ObjectId;

  @ApiProperty()
  title: string;

  @ApiPropertyOptional({ type: () => Object })
  team?: any;
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

export class TeamResponseDto {
  @ApiProperty({ type: String })
  _id: Types.ObjectId;

  @ApiProperty()
  name: string;

  @ApiPropertyOptional()
  avatar?: string;
}

export class ApplicationResponseDto {
  @ApiProperty({ type: String })
  _id: Types.ObjectId;

  @ApiProperty({ type: PostResponseDto })
  post: PostResponseDto;

  @ApiProperty({ type: UserResponseDto })
  applicant: UserResponseDto;

  @ApiPropertyOptional({ type: TeamResponseDto })
  team?: TeamResponseDto;

  @ApiProperty()
  coverLetter: string;

  @ApiPropertyOptional()
  resume?: string;

  @ApiProperty()
  skills: string[];

  @ApiProperty()
  experience: string;

  @ApiProperty()
  status: string;

  @ApiProperty()
  appliedAt: Date;

  @ApiPropertyOptional()
  reviewedAt?: Date;

  @ApiPropertyOptional({ type: UserResponseDto })
  reviewedBy?: UserResponseDto;

  @ApiPropertyOptional()
  notes?: string;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;
}