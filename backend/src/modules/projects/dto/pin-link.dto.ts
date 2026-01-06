import { IsString, IsNotEmpty, IsUrl } from 'class-validator';

export class PinLinkDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsUrl()
  @IsNotEmpty()
  url: string;
}