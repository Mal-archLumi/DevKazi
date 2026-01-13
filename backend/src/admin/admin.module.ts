// admin/admin.module.ts - UPDATED
import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';

// Controllers
import { AdminController } from './admin.controller';
import { AdminUsersController } from './controllers/admin-users.controller';
import { AdminTeamsController } from './controllers/admin-teams.controller';
import { AdminProjectsController } from './controllers/admin-projects.controller';
import { AdminAnalyticsController } from './controllers/admin-analytics.controller';

// Services
import { AdminUsersService } from './services/admin-users.service';
import { AdminTeamsService } from './services/admin-teams.service';
import { AdminProjectsService } from './services/admin-projects.service';
import { AdminAnalyticsService } from './services/admin-analytics.service';

// Schemas
import { User, UserSchema } from '../modules/users/schemas/user.schema';
import { Team, TeamSchema } from '../modules/teams/schemas/team.schema';
import { Project, ProjectSchema } from '../modules/projects/schemas/project.schema';
import { Message, MessageSchema } from '../modules/chat/schemas/message.schema';

// Guards
import { RolesGuard } from '../common/guards/roles.guard';
import { PermissionsGuard } from '../common/guards/permissions.guard';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: User.name, schema: UserSchema },
      { name: Team.name, schema: TeamSchema },
      { name: Project.name, schema: ProjectSchema },
      { name: Message.name, schema: MessageSchema },
    ]),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET'),
        signOptions: { expiresIn: '24h' },
      }),
      inject: [ConfigService],
    }),
  ],
  controllers: [
    AdminController,
    AdminUsersController,
    AdminTeamsController,
    AdminProjectsController,
    AdminAnalyticsController,
  ],
  providers: [
    AdminUsersService,
    AdminTeamsService,
    AdminProjectsService,
    AdminAnalyticsService,
    RolesGuard,
    PermissionsGuard,
  ],
  exports: [
    AdminUsersService,
    AdminAnalyticsService,
  ],
})
export class AdminModule {}