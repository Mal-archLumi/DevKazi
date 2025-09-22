import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Post } from './schemas/post.schema';

@Injectable()
export class PostsService {
  constructor(@InjectModel(Post.name) private postModel: Model<Post>) {}

  async create(createPostDto: any): Promise<Post> {
    const post = new this.postModel(createPostDto);
    return post.save();
  }

  async findAll(): Promise<Post[]> {
    return this.postModel.find()
      .populate('team', 'name projectName')
      .sort({ createdAt: -1 });
  }

  async findById(id: string): Promise<Post> {
    const post = await this.postModel.findById(id).populate('team');
    if (!post) {
      throw new NotFoundException('Post not found');
    }
    return post;
  }

  async findByType(type: string): Promise<Post[]> {
    return this.postModel.find({ type, status: 'active' })
      .populate('team', 'name projectName')
      .sort({ createdAt: -1 });
  }

  async updateApplicationCount(postId: string): Promise<Post> {
    const post = await this.postModel.findByIdAndUpdate(
      postId,
      { $inc: { applicationsCount: 1 } },
      { new: true }
    );
    if (!post) {
      throw new NotFoundException('Post not found');
    }
    return post;
  }
}