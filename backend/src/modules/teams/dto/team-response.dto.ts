import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Types } from 'mongoose';

export class TeamResponseDto {
  @ApiProperty()
  _id: Types.ObjectId;

  @ApiProperty()
  name: string;

  @ApiPropertyOptional()
  avatar?: string;

  @ApiPropertyOptional()
  description?: string;
}