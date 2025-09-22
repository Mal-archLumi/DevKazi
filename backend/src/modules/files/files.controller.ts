import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { FilesService } from './files.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@Controller('files')
@UseGuards(JwtAuthGuard)
export class FilesController {
  constructor(private readonly filesService: FilesService) {}

  @Post('presigned-url')
  async getPresignedUrl(@Body('filename') filename: string) {
    const url = await this.filesService.generatePresignedUrl(filename);
    return { url };
  }
}