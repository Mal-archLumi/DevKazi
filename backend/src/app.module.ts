// src/app.module.ts
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';

// Import modules
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { TeamsModule } from './modules/teams/teams.module';
import { ChatModule } from './modules/chat/chat.module';

// Import app controller and service
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CustomThrottlerGuard } from './common/guards/custom-throttler.guard';
import { JwtStrategy } from './auth/strategies/jwt.strategy';
import { WebSocketJwtStrategy } from './auth/strategies/websocket-jwt.strategy'; // NEW

@Module({
  imports: [
    // Configuration module
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    
    // JWT module using ConfigService
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET') || 'fallback-secret',
        signOptions: { expiresIn: '24h' },
      }),
      inject: [ConfigService],
    }),
    
    // Passport module for JWT
    PassportModule.register({ defaultStrategy: 'jwt' }),
    
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
    
    // MongoDB connection
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => {
        const uri = configService.get<string>('MONGODB_URI') || 'mongodb://localhost:27017/devkazi';
        
        console.log('🔧 Attempting MongoDB connection to Atlas...');
        
        return {
          uri,
          serverSelectionTimeoutMS: 30000, // 30 seconds
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
    ChatModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    JwtStrategy,
    WebSocketJwtStrategy, // NEW - Add WebSocket strategy at app level
    {
      provide: APP_GUARD,
      useClass: CustomThrottlerGuard,
    },
  ],
})
export class AppModule {}