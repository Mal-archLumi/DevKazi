import { Module, forwardRef } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ApplicationsController } from './applications.controller';
import { ApplicationsService } from './applications.service';
import { Application, ApplicationSchema } from './schemas/application.schema';
import { PostsModule } from '../posts/posts.module';
import { TeamsModule } from '../teams/teams.module';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Application.name, schema: ApplicationSchema }]),
    forwardRef(() => PostsModule),
    forwardRef(() => TeamsModule),
  ],
  controllers: [ApplicationsController],
  providers: [ApplicationsService],
  exports: [ApplicationsService],
})
export class ApplicationsModule {}