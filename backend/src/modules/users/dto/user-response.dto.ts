import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Types } from 'mongoose';

export class UserResponseDto {
  @ApiProperty({ type: String })
  _id: Types.ObjectId;

  @ApiProperty()
  email: string;

  @ApiProperty()
  name: string;

  @ApiProperty({ type: [String] })
  skills: string[];

  @ApiPropertyOptional()
  bio?: string;

  @ApiPropertyOptional()
  education?: string;

  @ApiPropertyOptional()
  avatar?: string;

  @ApiProperty()
  isVerified: boolean;

  @ApiProperty()
  isProfilePublic: boolean;

  @ApiProperty()
  isActive: boolean;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;
}

export class PublicUserResponseDto {
  @ApiProperty({ type: String })
  _id: Types.ObjectId;

  @ApiProperty()
  name: string;

  @ApiProperty({ type: [String] })
  skills: string[];

  @ApiPropertyOptional()
  bio?: string;

  @ApiPropertyOptional()
  avatar?: string;

  @ApiProperty()
  isVerified: boolean;
}