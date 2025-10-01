import { Model } from 'mongoose';
import { Post } from './schemas/post.schema';
export declare class PostsService {
    private postModel;
    constructor(postModel: Model<Post>);
    create(createPostDto: any): Promise<Post>;
    findAll(): Promise<Post[]>;
    findById(id: string): Promise<Post>;
    findByType(type: string): Promise<Post[]>;
    updateApplicationCount(postId: string): Promise<Post>;
}
