import { Injectable, CanActivate, ForbiddenException, ExecutionContext } from '@nestjs/common';
import { PostsService } from '../posts.service';

@Injectable()
export class PostOwnershipGuard implements CanActivate {
  constructor(private readonly postsService: PostsService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    const postId = request.params.id;

    const hasPermission = await this.postsService.checkPostOwnership(postId, user.userId);
    
    if (!hasPermission) {
      throw new ForbiddenException('You do not have permission to perform this action');
    }

    return true;
  }
}
