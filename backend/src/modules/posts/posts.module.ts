import { Module, forwardRef } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { PostsController } from './posts.controller';
import { PostsService } from './posts.service';
import { Post, PostSchema } from './schemas/post.schema';
import { TeamsModule } from '../teams/teams.module';
import { PostOwnershipGuard } from './guards/post-ownership.guard';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Post.name, schema: PostSchema }]),
    forwardRef(() => TeamsModule),
  ],
  controllers: [PostsController],
  providers: [PostsService, PostOwnershipGuard],
  exports: [PostsService],
})
export class PostsModule {}