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
import { Application, ApplicationDocument } from './schemas/application.schema';
import { CreateApplicationDto } from './dto/create-application.dto';
import { ApplicationStatusDto } from './dto/application-status.dto';
import { PostsService } from '../posts/posts.service';
import { TeamsService } from '../teams/teams.service';
import { ApplicationResponseDto } from './dto/application-response.dto';
import { UserResponseDto } from './dto/application-response.dto';
import { TeamResponseDto } from './dto/application-response.dto';
import { PostResponseDto } from './dto/application-response.dto';

@Injectable()
export class ApplicationsService {
  constructor(
    @InjectModel(Application.name) private applicationModel: Model<ApplicationDocument>,
    @Inject(forwardRef(() => PostsService))
    private postsService: PostsService,
    @Inject(forwardRef(() => TeamsService))
    private teamsService: TeamsService,
  ) {}

  async create(createApplicationDto: CreateApplicationDto, userId: string): Promise<ApplicationResponseDto> {
    const post = await this.postsService.findOne(createApplicationDto.post);
    
    // Validate post conditions
    this.validatePostForApplication(post);

    // Check for existing application
    const existingApplication = await this.applicationModel.findOne({
      post: new Types.ObjectId(createApplicationDto.post),
      applicant: new Types.ObjectId(userId),
    });

    if (existingApplication) {
      throw new BadRequestException('You have already applied to this post');
    }

    const applicationData: any = {
      ...createApplicationDto,
      post: new Types.ObjectId(createApplicationDto.post),
      applicant: new Types.ObjectId(userId),
    };

    // CHANGED: Only add team if post has a team
    if (post.team && post.team._id) {
      applicationData.team = post.team._id;
    }

    const application = new this.applicationModel(applicationData);
    await application.save();

    // Increment application count on post
    await this.postsService.incrementApplicationsCount(createApplicationDto.post);

    const populatedApplication = await this.applicationModel
      .findById(application._id)
      .populate('post', 'title team')
      .populate('applicant', 'name avatar email')
      .populate('team', 'name avatar')
      .exec();

    return this.mapToResponseDto(populatedApplication);
  }

  async getUserApplications(userId: string): Promise<ApplicationResponseDto[]> {
    const applications = await this.applicationModel
      .find({ applicant: new Types.ObjectId(userId) })
      .populate('post', 'title team applicationDeadline')
      .populate('team', 'name avatar')
      .populate('reviewedBy', 'name avatar')
      .sort({ appliedAt: -1 })
      .exec();

    return applications.map(app => this.mapToResponseDto(app));
  }

  async getTeamApplications(teamId: string, userId: string): Promise<ApplicationResponseDto[]> {
    // Verify user is team admin
    await this.teamsService.verifyTeamAdmin(teamId, userId);

    const applications = await this.applicationModel
      .find({ team: new Types.ObjectId(teamId) })
      .populate('post', 'title')
      .populate('applicant', 'name avatar email skills')
      .populate('reviewedBy', 'name avatar')
      .sort({ appliedAt: -1 })
      .exec();

    return applications.map(app => this.mapToResponseDto(app));
  }

  async updateStatus(
    applicationId: string, 
    statusDto: ApplicationStatusDto, 
    userId: string
  ): Promise<ApplicationResponseDto> {
    const application = await this.applicationModel.findById(applicationId);
    
    if (!application) {
      throw new NotFoundException('Application not found');
    }

    // CHANGED: If application has a team, verify team admin, otherwise verify post creator
    if (application.team) {
      await this.teamsService.verifyTeamAdmin(application.team.toString(), userId);
    } else {
      // Verify the user is the post creator for posts without teams
      const post = await this.postsService.findOne(application.post.toString());
      if (post.createdBy._id.toString() !== userId) {
        throw new ForbiddenException('Only the post creator can manage applications for this post');
      }
    }

    // Validate status transition
    this.validateStatusTransition(application.status, statusDto.status);

    const updatedApplication = await this.applicationModel
      .findByIdAndUpdate(
        applicationId,
        {
          status: statusDto.status,
          reviewedAt: new Date(),
          reviewedBy: new Types.ObjectId(userId),
          notes: statusDto.notes,
        },
        { new: true, runValidators: true }
      )
      .populate('post', 'title team')
      .populate('applicant', 'name avatar email')
      .populate('team', 'name avatar')
      .populate('reviewedBy', 'name avatar')
      .exec();

    return this.mapToResponseDto(updatedApplication);
  }

  async getApplicationStats(teamId: string, userId: string): Promise<{ [key: string]: number }> {
    // Verify user is team admin
    await this.teamsService.verifyTeamAdmin(teamId, userId);

    const stats = await this.applicationModel.aggregate([
      { $match: { team: new Types.ObjectId(teamId) } },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 }
        }
      }
    ]);

    return stats.reduce((acc, curr) => {
      acc[curr._id] = curr.count;
      return acc;
    }, { pending: 0, accepted: 0, rejected: 0, withdrawn: 0 });
  }

  async getApplicationAnalytics(teamId: string, userId: string): Promise<any> {
    // Verify user is team admin
    await this.teamsService.verifyTeamAdmin(teamId, userId);

    const analytics = await this.applicationModel.aggregate([
      { $match: { team: new Types.ObjectId(teamId) } },
      {
        $lookup: {
          from: 'posts',
          localField: 'post',
          foreignField: '_id',
          as: 'postDetails'
        }
      },
      { $unwind: '$postDetails' },
      {
        $group: {
          _id: '$post',
          postTitle: { $first: '$postDetails.title' },
          statusBreakdown: {
            $push: {
              status: '$status',
              count: 1
            }
          },
          totalApplications: { $sum: 1 }
        }
      },
      {
        $project: {
          postTitle: 1,
          totalApplications: 1,
          statusBreakdown: {
            $arrayToObject: {
              $map: {
                input: '$statusBreakdown',
                as: 'item',
                in: {
                  k: '$$item.status',
                  v: '$$item.count'
                }
              }
            }
          }
        }
      }
    ]);

    return analytics;
  }

  async withdrawApplication(applicationId: string, userId: string): Promise<ApplicationResponseDto> {
    const application = await this.applicationModel.findById(applicationId);
    
    if (!application) {
      throw new NotFoundException('Application not found');
    }

    // Verify user owns the application
    if (application.applicant.toString() !== userId) {
      throw new ForbiddenException('You can only withdraw your own applications');
    }

    // Validate status transition
    if (application.status !== 'pending') {
      throw new BadRequestException('Cannot withdraw a processed application');
    }

    const updatedApplication = await this.applicationModel
      .findByIdAndUpdate(
        applicationId,
        {
          status: 'withdrawn',
          reviewedAt: new Date(),
        },
        { new: true }
      )
      .populate('post', 'title team')
      .populate('applicant', 'name avatar email')
      .populate('team', 'name avatar')
      .exec();

    return this.mapToResponseDto(updatedApplication);
  }

  private validatePostForApplication(post: any): void {
    if (post.status !== 'active') {
      throw new BadRequestException('Cannot apply to an inactive post');
    }

    if (new Date(post.applicationDeadline) < new Date()) {
      throw new BadRequestException('Application deadline has passed');
    }
  }

  private validateStatusTransition(currentStatus: string, newStatus: string): void {
    const validTransitions: { [key: string]: string[] } = {
      'pending': ['accepted', 'rejected', 'withdrawn'],
      'accepted': ['withdrawn'],
      'rejected': ['withdrawn'],
      'withdrawn': []
    };

    if (!validTransitions[currentStatus]?.includes(newStatus)) {
      throw new BadRequestException(`Invalid status transition from ${currentStatus} to ${newStatus}`);
    }
  }

 private mapToResponseDto(application: any): ApplicationResponseDto {
  if (!application) {
    throw new NotFoundException('Application not found');
  }

  // Handle post data
  const postDto: PostResponseDto = application.post && typeof application.post === 'object' ? {
    _id: application.post._id,
    title: application.post.title,
    team: application.post.team,
  } : {
    _id: application.post || new Types.ObjectId(),
    title: 'Unknown Post',
    team: undefined,
  };

  // Handle applicant
  const applicantDto: UserResponseDto = application.applicant && typeof application.applicant === 'object' ? {
    _id: application.applicant._id,
    name: application.applicant.name,
    avatar: application.applicant.avatar,
    email: application.applicant.email,
  } : {
    _id: new Types.ObjectId(),
    name: 'Unknown User',
    avatar: undefined,
    email: undefined,
  };

  // Handle team - can be undefined
  const teamDto: TeamResponseDto | undefined = application.team && typeof application.team === 'object' ? {
    _id: application.team._id,
    name: application.team.name,
    avatar: application.team.avatar,
  } : undefined;

  // Handle reviewedBy - can be undefined
  const reviewedByDto: UserResponseDto | undefined = application.reviewedBy && typeof application.reviewedBy === 'object' ? {
    _id: application.reviewedBy._id,
    name: application.reviewedBy.name,
    avatar: application.reviewedBy.avatar,
    email: application.reviewedBy.email,
  } : undefined;

  return {
    _id: application._id,
    post: postDto,
    applicant: applicantDto,
    team: teamDto,
    coverLetter: application.coverLetter,
    resume: application.resume,
    skills: application.skills,
    experience: application.experience,
    status: application.status,
    appliedAt: application.appliedAt,
    reviewedAt: application.reviewedAt,
    reviewedBy: reviewedByDto,
    notes: application.notes,
    createdAt: application.createdAt,
    updatedAt: application.updatedAt,
  };
 }
}