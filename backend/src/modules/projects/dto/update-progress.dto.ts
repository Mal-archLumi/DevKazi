// src/modules/projects/dto/update-progress.dto.ts
import { IsNumber, Min, Max, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateProgressDto {
  @ApiProperty({ description: 'Project progress from 0 to 1', example: 0.75 })
  @IsNumber()
  @Min(0)
  @Max(1)
  @IsNotEmpty()
  progress: number;
}