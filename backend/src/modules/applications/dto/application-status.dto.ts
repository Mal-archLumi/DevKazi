import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ApplicationStatusDto {
  @ApiProperty({ 
    description: 'Application status', 
    enum: ['accepted', 'rejected', 'withdrawn'] 
  })
  @IsEnum(['accepted', 'rejected', 'withdrawn'])
  status: string;

  @ApiPropertyOptional({ 
    description: 'Internal notes', 
    maxLength: 500 
  })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  notes?: string;
}