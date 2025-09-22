import { PostsService } from './posts.service';
export declare class PostsController {
    private readonly postsService;
    constructor(postsService: PostsService);
    create(createPostDto: any): Promise<import("./schemas/post.schema").Post>;
    findAll(type?: string): Promise<import("./schemas/post.schema").Post[]>;
    findOne(id: string): Promise<import("./schemas/post.schema").Post>;
}
