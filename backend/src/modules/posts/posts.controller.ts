import { 
  Controller, 
  Get, 
  Post, 
  Put, 
  Delete, 
  Body, 
  Param, 
  Query, 
  UseGuards, 
  Req,
  HttpStatus,
  HttpCode
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { PostsService } from './posts.service';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';
import { SearchPostsDto } from './dto/search-posts.dto';
import { PostResponseDto } from './dto/post-response.dto';
import { PostOwnershipGuard } from './guards/post-ownership.guard';

@ApiTags('posts')
@Controller('posts')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class PostsController {
  constructor(private readonly postsService: PostsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new internship post' })
  @ApiResponse({ status: 201, description: 'Post created successfully', type: PostResponseDto })
  @ApiResponse({ status: 403, description: 'Forbidden - No team permission' })
  async create(@Body() createPostDto: CreatePostDto, @Req() req: any): Promise<PostResponseDto> {
    return this.postsService.create(createPostDto, req.user.userId);
  }

  @Get()
  @ApiOperation({ summary: 'Get all internship posts with filtering' })
  @ApiResponse({ status: 200, description: 'Posts retrieved successfully' })
  async findAll(@Query() searchDto: SearchPostsDto): Promise<{ posts: PostResponseDto[]; total: number }> {
    return this.postsService.findAll(searchDto);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a specific post by ID' })
  @ApiResponse({ status: 200, description: 'Post retrieved successfully', type: PostResponseDto })
  @ApiResponse({ status: 404, description: 'Post not found' })
  async findOne(@Param('id') id: string): Promise<PostResponseDto> {
    return this.postsService.findOne(id);
  }

  @Put(':id')
  @UseGuards(PostOwnershipGuard)
  @ApiOperation({ summary: 'Update a post' })
  @ApiResponse({ status: 200, description: 'Post updated successfully', type: PostResponseDto })
  @ApiResponse({ status: 404, description: 'Post not found' })
  async update(
    @Param('id') id: string, 
    @Body() updatePostDto: UpdatePostDto,
    @Req() req: any
  ): Promise<PostResponseDto> {
    return this.postsService.update(id, updatePostDto, req.user.userId);
  }

  @Delete(':id')
  @UseGuards(PostOwnershipGuard)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a post' })
  @ApiResponse({ status: 204, description: 'Post deleted successfully' })
  @ApiResponse({ status: 404, description: 'Post not found' })
  async remove(@Param('id') id: string, @Req() req: any): Promise<void> {
    return this.postsService.remove(id, req.user.userId);
  }

  @Get('team/:teamId')
  @ApiOperation({ summary: 'Get all posts for a specific team' })
  @ApiResponse({ status: 200, description: 'Team posts retrieved successfully' })
  async getTeamPosts(@Param('teamId') teamId: string, @Req() req: any): Promise<PostResponseDto[]> {
    return this.postsService.getTeamPosts(teamId, req.user.userId);
  }
}