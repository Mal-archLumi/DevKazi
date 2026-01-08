import { ApiProperty } from '@nestjs/swagger';

export class UserResponseDto {
  @ApiProperty()
  _id: string;

  @ApiProperty()
  email: string;

  @ApiProperty()
  name: string;

  @ApiProperty({ type: [String] })
  skills: string[];

  @ApiProperty({ required: false, nullable: true })
  bio?: string;

  @ApiProperty({ required: false, nullable: true })
  education?: string;

  @ApiProperty({ required: false, nullable: true })
  picture?: string;

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

  @ApiProperty({ description: 'Number of teams the user belongs to', default: 0 })
  teamCount: number;

  @ApiProperty({ description: 'Number of projects the user owns', default: 0 })
  projectCount: number;
}

export class PublicUserResponseDto {
  @ApiProperty()
  _id: string;

  @ApiProperty()
  name: string;

  @ApiProperty({ type: [String] })
  skills: string[];

  @ApiProperty({ required: false, nullable: true })
  bio?: string;

  @ApiProperty({ required: false, nullable: true })
  picture?: string;

  @ApiProperty()
  isVerified: boolean;

  @ApiProperty({ description: 'Number of teams the user belongs to', default: 0 })
  teamCount: number;
}