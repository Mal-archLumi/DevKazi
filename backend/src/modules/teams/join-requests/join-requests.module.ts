// teams/join-requests/join-requests.module.ts
import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JoinRequestsController } from './join-requests.controller';
import { JoinRequestsService } from './join-requests.service';
import { JoinRequest, JoinRequestSchema } from '../schemas/join-request.schema';
import { Team, TeamSchema } from '../schemas/team.schema';
import { User, UserSchema } from '../../users/schemas/user.schema';
import { TeamsModule } from '../teams.module'; // This imports TeamsService
import { UsersModule } from '../../users/users.module'; // This imports UsersService
import { NotificationsModule } from '../../notifications/notifications.module'; // This imports NotificationsService

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: JoinRequest.name, schema: JoinRequestSchema },
      { name: Team.name, schema: TeamSchema },
      { name: User.name, schema: UserSchema },
    ]),
    TeamsModule, // ✅ Provides TeamsService
    UsersModule, // ✅ Provides UsersService  
    NotificationsModule, // ✅ Provides NotificationsService
  ],
  controllers: [JoinRequestsController],
  providers: [JoinRequestsService],
  exports: [JoinRequestsService],
})
export class JoinRequestsModule {}