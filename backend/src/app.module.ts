// app.module.ts
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';

// Import modules IN THIS ORDER
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { TeamsModule } from './modules/teams/teams.module';
import { JoinRequestsModule } from './modules/teams/join-requests/join-requests.module';
import { ChatModule } from './modules/chat/chat.module';
import { ProjectsModule } from './modules/projects/projects.module';
import { NotificationsModule } from './modules/notifications/notifications.module';

// Import app controller and service
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CustomThrottlerGuard } from './common/guards/custom-throttler.guard';
import { JwtStrategy } from './auth/strategies/jwt.strategy';
import { WebSocketJwtStrategy } from './auth/strategies/websocket-jwt.strategy';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET') || 'fallback-secret',
        signOptions: { expiresIn: '24h' },
      }),
      inject: [ConfigService],
    }),
    
    PassportModule.register({ defaultStrategy: 'jwt' }),
    
    ThrottlerModule.forRoot([
      {
        name: 'auth',
        ttl: 60000,
        limit: 10,
      },
      {
        name: 'api',
        ttl: 60000,
        limit: 100,
      },
      {
        name: 'strict',
        ttl: 60000,
        limit: 5,
      }
    ]),
    
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => {
        const uri = configService.get<string>('MONGODB_URI') || 'mongodb://localhost:27017/devkazi';
        console.log('🔧 Attempting MongoDB connection...');
        
        return {
          uri,
          serverSelectionTimeoutMS: 30000,
          socketTimeoutMS: 45000,
          connectTimeoutMS: 30000,
          maxPoolSize: 10,
          retryWrites: true,
          retryReads: true,
        };
      },
      inject: [ConfigService],
    }),
    
    // Feature modules
    AuthModule,
    UsersModule,
    TeamsModule,
    JoinRequestsModule, // ✅ Ensure this is here
    ChatModule,
    ProjectsModule,
    NotificationsModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    JwtStrategy,
    WebSocketJwtStrategy,
    {
      provide: APP_GUARD,
      useClass: CustomThrottlerGuard,
    },
  ],
})
export class AppModule {
  constructor() {
    console.log('🟢 AppModule initialized');
    console.log('📋 Modules loaded:', [
      'AuthModule',
      'UsersModule', 
      'TeamsModule',
      'JoinRequestsModule',
      'ChatModule',
      'ProjectsModule',
      'NotificationsModule'
    ]);
  }
}