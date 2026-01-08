// teams/teams.module.ts
import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { TeamsController } from './teams.controller';
import { TeamsService } from './teams.service';
import { Team, TeamSchema } from './schemas/team.schema';
import { User, UserSchema } from '../users/schemas/user.schema';
import { JoinRequest, JoinRequestSchema } from './schemas/join-request.schema';
// REMOVED NotificationsModule import

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Team.name, schema: TeamSchema },
      { name: User.name, schema: UserSchema },
      { name: JoinRequest.name, schema: JoinRequestSchema },
    ]),
    // REMOVED NotificationsModule - no circular dependency
  ],
  controllers: [TeamsController],
  providers: [TeamsService],
  exports: [TeamsService, MongooseModule],
})
export class TeamsModule {}