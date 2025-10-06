import { PostsService } from './posts.service';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';
import { SearchPostsDto } from './dto/search-posts.dto';
import { PostResponseDto } from './dto/post-response.dto';
export declare class PostsController {
    private readonly postsService;
    constructor(postsService: PostsService);
    create(createPostDto: CreatePostDto, req: any): Promise<PostResponseDto>;
    findAll(searchDto: SearchPostsDto): Promise<{
        posts: PostResponseDto[];
        total: number;
    }>;
    findOne(id: string): Promise<PostResponseDto>;
    update(id: string, updatePostDto: UpdatePostDto, req: any): Promise<PostResponseDto>;
    remove(id: string, req: any): Promise<void>;
    getTeamPosts(teamId: string, req: any): Promise<PostResponseDto[]>;
}
