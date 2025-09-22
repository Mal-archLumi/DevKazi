import { Injectable } from '@nestjs/common';

@Injectable()
export class FilesService {
  async generatePresignedUrl(filename: string): Promise<string> {
    // This will be implemented later with AWS S3
    return `https://your-s3-bucket.s3.amazonaws.com/${filename}`;
  }
}