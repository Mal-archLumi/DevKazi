// src/app.module.ts
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { MongooseModule } from '@nestjs/mongoose';

// Import modules
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { TeamsModule } from './modules/teams/teams.module';
import { ChatModule } from './modules/chat/chat.module';

// Import app controller and service
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CustomThrottlerGuard } from './common/guards/custom-throttler.guard';

@Module({
  imports: [
    // Configuration module
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    
    // Enhanced Rate limiting with multiple rules
    ThrottlerModule.forRoot([
      {
        name: 'auth',
        ttl: 60000, // 1 minute
        limit: 10, // 10 requests per minute for auth
      },
      {
        name: 'api',
        ttl: 60000, // 1 minute
        limit: 100, // 100 requests per minute for general API
      },
      {
        name: 'strict',
        ttl: 60000, // 1 minute
        limit: 5, // 5 requests per minute for sensitive endpoints
      }
    ]),
    
    // MongoDB connection with timeout and retry logic
    MongooseModule.forRoot(process.env.MONGODB_URI || 'mongodb://localhost:27017/devkazi', {
      connectionFactory: (connection) => {
        connection.on('connected', () => {
          console.log('MongoDB connected successfully');
        });
        connection.on('error', (error: Error) => {
          console.error('MongoDB connection error:', error);
        });
        connection.on('disconnected', () => {
          console.log('MongoDB disconnected');
        });
        return connection;
      },
      connectTimeoutMS: 10000,
      socketTimeoutMS: 45000,
      maxPoolSize: 10,
      minPoolSize: 5,
      retryAttempts: 3,
      retryDelay: 1000,
    }),
    
    // Feature modules
    AuthModule,
    UsersModule,
    TeamsModule,
    ChatModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_GUARD,
      useClass: CustomThrottlerGuard,
    },
  ],
})
export class AppModule {}