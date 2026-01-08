// notifications/dto/notification-response.dto.ts
import { ApiProperty } from '@nestjs/swagger';
import { NotificationType } from '../schemas/notification.schema';

export class NotificationResponseDto {
  @ApiProperty()
  _id: string;

  @ApiProperty()
  userId: string;

  @ApiProperty({ enum: NotificationType })
  type: NotificationType;

  @ApiProperty()
  title: string;

  @ApiProperty()
  message: string;

  @ApiProperty({ required: false })
  teamId?: {
    _id: string;
    name: string;
  };

  @ApiProperty({ required: false })
  projectId?: {
    _id: string;
    title: string;
  };

  @ApiProperty({ required: false })
  triggeredBy?: {
    _id: string;
    name: string;
    email: string;
    picture?: string;
  };

  @ApiProperty()
  isRead: boolean;

  @ApiProperty({ required: false })
  actionUrl?: string;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;
}