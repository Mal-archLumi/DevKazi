import { CanActivate, ExecutionContext } from '@nestjs/common';
import { PostsService } from '../posts.service';
export declare class PostOwnershipGuard implements CanActivate {
    private readonly postsService;
    constructor(postsService: PostsService);
    canActivate(context: ExecutionContext): Promise<boolean>;
}
