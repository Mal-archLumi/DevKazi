import { Model } from 'mongoose';
import { PostDocument } from './schemas/post.schema';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';
import { SearchPostsDto } from './dto/search-posts.dto';
import { TeamsService } from '../teams/teams.service';
import { PostResponseDto } from './dto/post-response.dto';
export declare class PostsService {
    private postModel;
    private teamsService;
    constructor(postModel: Model<PostDocument>, teamsService: TeamsService);
    create(createPostDto: CreatePostDto, userId: string): Promise<PostResponseDto>;
    findAll(searchDto: SearchPostsDto): Promise<{
        posts: PostResponseDto[];
        total: number;
    }>;
    findOne(id: string): Promise<PostResponseDto>;
    update(id: string, updatePostDto: UpdatePostDto, userId: string): Promise<PostResponseDto>;
    remove(id: string, userId: string): Promise<void>;
    getTeamPosts(teamId: string, userId: string): Promise<PostResponseDto[]>;
    checkPostOwnership(postId: string, userId: string): Promise<boolean>;
    incrementApplicationsCount(postId: string): Promise<void>;
    private verifyTeamPermission;
    private mapToResponseDto;
}
