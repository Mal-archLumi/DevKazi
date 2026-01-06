// join-requests/join-requests.module.ts
import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JoinRequestsController } from './join-requests.controller';
import { JoinRequestsService } from './join-requests.service';
import { JoinRequest, JoinRequestSchema } from '../schemas/join-request.schema';
import { Team, TeamSchema } from '../schemas/team.schema';
import { User, UserSchema } from '../../users/schemas/user.schema'; // ✅ ADD THIS
import { TeamsService } from '../teams.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: JoinRequest.name, schema: JoinRequestSchema },
      { name: Team.name, schema: TeamSchema },
      { name: User.name, schema: UserSchema }, // ✅ ADD THIS
    ]),
  ],
  controllers: [JoinRequestsController],
  providers: [JoinRequestsService, TeamsService],
  exports: [JoinRequestsService],
})
export class JoinRequestsModule {}