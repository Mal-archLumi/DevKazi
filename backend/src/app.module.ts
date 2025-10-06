import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { MongooseModule } from '@nestjs/mongoose';

// Import modules
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { TeamsModule } from './modules/teams/teams.module';
import { PostsModule } from './modules/posts/posts.module';
import { ApplicationsModule } from './modules/applications/applications.module';
import { ChatModule } from './modules/chat/chat.module';
import { FilesModule } from './modules/files/files.module';

// Import app controller and service
import { AppController } from './app.controller';
import { AppService } from './app.service';

@Module({
  imports: [
    // Configuration module with environment file support
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    
    // Rate limiting configuration
    ThrottlerModule.forRoot([{
      ttl: 60000, // 1 minute
      limit: 100, // 100 requests per minute
    }]),
    
    // MongoDB connection
    MongooseModule.forRoot(process.env.MONGODB_URI || 'mongodb://localhost:27017/devkazi'),
    
    // Feature modules - keeping all your existing modules
    AuthModule,
    UsersModule,
    TeamsModule,        // Teams module integration
    PostsModule,        // Phase 4 - Internship Posts
    ApplicationsModule, // Phase 4 - Applications
    ChatModule,         // Phase 5 - Real-time Chat
    FilesModule,        // Phase 6 - File Uploads
  ],
  controllers: [AppController],
  providers: [
    AppService,
    // Add global ThrottlerGuard for enhanced security (from my version)
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}