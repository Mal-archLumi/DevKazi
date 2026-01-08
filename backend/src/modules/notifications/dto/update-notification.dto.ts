// notifications/dto/update-notification.dto.ts
import { IsBoolean, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateNotificationDto {
  @ApiProperty({ required: false })
  @IsBoolean()
  @IsOptional()
  isRead?: boolean;
}