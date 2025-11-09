// src/auth/auth.module.ts
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtStrategy } from './strategies/jwt.strategy';
import { WebSocketJwtStrategy } from './strategies/websocket-jwt.strategy'; // NEW
import { MongooseModule } from '@nestjs/mongoose';
import { User, UserSchema } from '../modules/users/schemas/user.schema';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { WebSocketJwtAuthGuard } from './guards/websocket-jwt-auth.guard'; // NEW

@Module({
  imports: [
    MongooseModule.forFeature([{ name: User.name, schema: UserSchema }]),
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'fallback-secret',
      signOptions: { expiresIn: '24h' },
    }),
  ],
  controllers: [AuthController],
  providers: [
    AuthService, 
    JwtStrategy,
    WebSocketJwtStrategy, // NEW
    JwtAuthGuard,
    WebSocketJwtAuthGuard, // NEW
  ],
  exports: [
    AuthService, 
    JwtStrategy,
    WebSocketJwtStrategy, // NEW
    JwtAuthGuard,
    WebSocketJwtAuthGuard, // NEW
  ],
})
export class AuthModule {}