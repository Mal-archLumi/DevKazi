import { IsString, IsNotEmpty } from 'class-validator';

export class AddIdeaDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsNotEmpty()
  description: string;
}