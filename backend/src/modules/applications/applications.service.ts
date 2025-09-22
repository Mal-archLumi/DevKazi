import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Application } from './schemas/application.schema';

@Injectable()
export class ApplicationsService {
  constructor(@InjectModel(Application.name) private applicationModel: Model<Application>) {}

  async create(createApplicationDto: any): Promise<Application> {
    const application = new this.applicationModel(createApplicationDto);
    return application.save();
  }

  async findByUser(userId: string): Promise<Application[]> {
    return this.applicationModel.find({ applicant: userId })
      .populate('post', 'title type')
      .populate('team', 'name')
      .sort({ createdAt: -1 });
  }

  async findByPost(postId: string): Promise<Application[]> {
    return this.applicationModel.find({ post: postId })
      .populate('applicant', 'name email skills')
      .sort({ createdAt: -1 });
  }

  async updateStatus(applicationId: string, status: string): Promise<Application> {
    const application = await this.applicationModel.findByIdAndUpdate(
      applicationId,
      { status },
      { new: true }
    );
    if (!application) {
      throw new NotFoundException('Application not found');
    }
    return application;
  }
}