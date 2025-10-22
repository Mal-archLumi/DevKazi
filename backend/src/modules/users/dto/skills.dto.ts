import { IsArray, IsString, ArrayNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class AddSkillsDto {
  @ApiProperty({ example: ['JavaScript', 'TypeScript'], description: 'Skills to add' })
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  skills: string[];
}

export class RemoveSkillsDto {
  @ApiProperty({ example: ['Python'], description: 'Skills to remove' })
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  skills: string[];
}