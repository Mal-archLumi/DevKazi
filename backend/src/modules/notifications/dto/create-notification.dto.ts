// notifications/dto/create-notification.dto.ts
import { IsEnum, IsNotEmpty, IsOptional, IsString, IsMongoId } from 'class-validator';
import { NotificationType } from '../schemas/notification.schema';
import { ApiProperty } from '@nestjs/swagger';

export class CreateNotificationDto {
  @ApiProperty({ enum: NotificationType })
  @IsEnum(NotificationType)
  @IsNotEmpty()
  type: NotificationType;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  message: string;

  @ApiProperty({ required: false })
  @IsMongoId()
  @IsOptional()
  teamId?: string;

  @ApiProperty({ required: false })
  @IsMongoId()
  @IsOptional()
  projectId?: string;

  @ApiProperty({ required: false })
  @IsMongoId()
  @IsOptional()
  triggeredBy?: string;

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  actionUrl?: string;
}