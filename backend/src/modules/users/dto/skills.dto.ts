import { IsArray, IsString, ArrayNotEmpty, ArrayMinSize } from 'class-validator';

export class AddSkillsDto {
  @IsArray()
  @ArrayNotEmpty()
  @ArrayMinSize(1)
  @IsString({ each: true })
  skills: string[];
}

export class RemoveSkillsDto {
  @IsArray()
  @ArrayNotEmpty()
  @ArrayMinSize(1)
  @IsString({ each: true })
  skills: string[];
}