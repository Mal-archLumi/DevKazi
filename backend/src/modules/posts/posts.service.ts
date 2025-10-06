import { 
  Injectable, 
  NotFoundException, 
  ForbiddenException,
  BadRequestException,
  Inject,
  forwardRef 
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Post, PostDocument } from './schemas/post.schema';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';
import { SearchPostsDto } from './dto/search-posts.dto';
import { TeamsService } from '../teams/teams.service';
// FIXED: Import from the correct location - use local DTOs
import { PostResponseDto, TeamResponseDto, UserResponseDto } from './dto/post-response.dto';

@Injectable()
export class PostsService {
  constructor(
    @InjectModel(Post.name) private postModel: Model<PostDocument>,
    @Inject(forwardRef(() => TeamsService))
    private teamsService: TeamsService,
  ) {}

  async create(createPostDto: CreatePostDto, userId: string): Promise<PostResponseDto> {
    // CHANGED: Only verify team permission if team is provided
    if (createPostDto.team) {
      await this.verifyTeamPermission(createPostDto.team, userId);
    }

    const postData: any = {
      ...createPostDto,
      createdBy: new Types.ObjectId(userId),
    };

    // CHANGED: Only add team if provided
    if (createPostDto.team) {
      postData.team = new Types.ObjectId(createPostDto.team);
    }

    const post = await this.postModel.create(postData);
    
    // Populate and return as DTO
    const populatedPost = await this.postModel
      .findById(post._id)
      .populate('team', 'name avatar description')
      .populate('createdBy', 'name avatar email')
      .exec();

    return this.mapToResponseDto(populatedPost);
  }

  async findAll(searchDto: SearchPostsDto): Promise<{ posts: PostResponseDto[]; total: number }> {
    const { 
      page = 1, 
      limit = 10, 
      search, 
      category, 
      skills, 
      location, 
      commitment, 
      minStipend, 
      maxStipend,
      sortBy,
      sortOrder 
    } = searchDto;

    const query: any = { 
      status: 'active', 
      isPublic: true,
      applicationDeadline: { $gte: new Date() }
    };

    // Text search
    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { tags: { $in: [new RegExp(search, 'i')] } }
      ];
    }

    // Exact matches
    if (category) query.category = category;
    if (location) query.location = location;
    if (commitment) query.commitment = commitment;

    // Array matches
    if (skills && skills.length > 0) {
      query.skillsRequired = { $in: skills };
    }

    // Range queries
    if (minStipend !== undefined || maxStipend !== undefined) {
      query.stipend = {};
      if (minStipend !== undefined) query.stipend.$gte = minStipend;
      if (maxStipend !== undefined) query.stipend.$lte = maxStipend;
    }

    const sortOptions: any = {};
    sortOptions[sortBy || 'createdAt'] = sortOrder === 'desc' ? -1 : 1;

    const posts = await this.postModel
      .find(query)
      .populate('team', 'name avatar description')
      .populate('createdBy', 'name avatar email')
      .sort(sortOptions)
      .skip((page - 1) * limit)
      .limit(limit)
      .exec();

    const total = await this.postModel.countDocuments(query);

    return { 
      posts: posts.map(post => this.mapToResponseDto(post)), 
      total 
    };
  }

  async findOne(id: string): Promise<PostResponseDto> {
    if (!Types.ObjectId.isValid(id)) {
      throw new NotFoundException('Post not found');
    }

    const post = await this.postModel
      .findById(id)
      .populate('team', 'name avatar description members')
      .populate('createdBy', 'name avatar email')
      .exec();

    if (!post) {
      throw new NotFoundException('Post not found');
    }

    return this.mapToResponseDto(post);
  }

  async update(id: string, updatePostDto: UpdatePostDto, userId: string): Promise<PostResponseDto> {
    await this.checkPostOwnership(id, userId);

    const post = await this.postModel
      .findByIdAndUpdate(id, updatePostDto, { new: true, runValidators: true })
      .populate('team', 'name avatar description')
      .populate('createdBy', 'name avatar email')
      .exec();

    if (!post) {
      throw new NotFoundException('Post not found');
    }

    return this.mapToResponseDto(post);
  }

  async remove(id: string, userId: string): Promise<void> {
    await this.checkPostOwnership(id, userId);
    
    const result = await this.postModel.findByIdAndDelete(id).exec();
    if (!result) {
      throw new NotFoundException('Post not found');
    }
  }

  async getTeamPosts(teamId: string, userId: string): Promise<PostResponseDto[]> {
    // Verify user is team member
    await this.teamsService.verifyTeamMembership(teamId, userId);

    const posts = await this.postModel
      .find({ team: new Types.ObjectId(teamId) })
      .populate('team', 'name avatar description')
      .populate('createdBy', 'name avatar email')
      .sort({ createdAt: -1 })
      .exec();

    return posts.map(post => this.mapToResponseDto(post));
  }

  async checkPostOwnership(postId: string, userId: string): Promise<boolean> {
    const post = await this.postModel.findById(postId).exec();
    if (!post) {
      throw new NotFoundException('Post not found');
    }

    // CHANGED: Only verify team permission if post has a team
    if (post.team) {
      return this.verifyTeamPermission(post.team.toString(), userId);
    }

    // CHANGED: If no team, only the creator can manage the post
    return post.createdBy.toString() === userId;
  }

  async incrementApplicationsCount(postId: string): Promise<void> {
    await this.postModel.findByIdAndUpdate(postId, {
      $inc: { applicationsCount: 1 }
    }).exec();
  }

  private async verifyTeamPermission(teamId: string, userId: string): Promise<boolean> {
    const team = await this.teamsService.getTeamById(teamId);
    const isAdmin = team.members.some(member => 
      member.user.toString() === userId && ['owner', 'admin'].includes(member.role)
    );

    if (!isAdmin) {
      throw new ForbiddenException('You do not have permission to manage posts for this team');
    }

    return true;
  }

  private mapToResponseDto(post: any): PostResponseDto {
    if (!post) throw new Error('Post data is required');

    // Handle team - can be undefined
    const teamDto: TeamResponseDto | undefined = post.team && typeof post.team === 'object' ? {
      _id: post.team._id,
      name: post.team.name,
      avatar: post.team.avatar,
      description: post.team.description,
    } : undefined;

    // Handle createdBy
    const createdByDto: UserResponseDto = post.createdBy && typeof post.createdBy === 'object' ? {
      _id: post.createdBy._id,
      name: post.createdBy.name,
      avatar: post.createdBy.avatar,
      email: post.createdBy.email,
    } : {
      _id: new Types.ObjectId(),
      name: 'Unknown User',
      email: undefined,
      avatar: undefined,
    };

    return {
      _id: post._id,
      title: post.title,
      description: post.description,
      requirements: post.requirements,
      skillsRequired: post.skillsRequired,
      category: post.category,
      team: teamDto, // Can be undefined
      createdBy: createdByDto,
      applicationDeadline: post.applicationDeadline,
      duration: post.duration,
      commitment: post.commitment,
      location: post.location,
      stipend: post.stipend,
      positions: post.positions,
      applicationsCount: post.applicationsCount,
      status: post.status,
      tags: post.tags,
      isPublic: post.isPublic,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
    };
  }
}