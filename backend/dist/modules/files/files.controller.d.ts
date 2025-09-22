import { FilesService } from './files.service';
export declare class FilesController {
    private readonly filesService;
    constructor(filesService: FilesService);
    getPresignedUrl(filename: string): Promise<{
        url: string;
    }>;
}
