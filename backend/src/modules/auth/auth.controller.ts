import { Controller, Post, Body, UnauthorizedException, BadRequestException, UseGuards, Req, Put } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { JwtAuthGuard } from 'src/common/guards/jwt-auth.guard';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  async login(@Body() loginDto: LoginDto) {
    const user = await this.authService.validateUser(loginDto.email, loginDto.password);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }
    return this.authService.login(user);
  }

  @Post('register')
  async register(@Body() registerDto: RegisterDto) {
    // Check if user already exists
    const existingUser = await this.authService['userModel'].findOne({ email: registerDto.email });
    if (existingUser) {
      throw new BadRequestException('User already exists with this email');
    }

    const user = await this.authService.register(registerDto);
    return this.authService.login(user);
  }

  @Post('refresh')
  async refresh(@Body() refreshTokenDto: RefreshTokenDto) {
    return this.authService.refreshToken(refreshTokenDto.refresh_token);
  }

  @Post('logout')
  @UseGuards(JwtAuthGuard)
  async logout(@Req() req: any) {
    return this.authService.logout(req.user.userId);
  }
  
  @Put('change-password')
  @UseGuards(JwtAuthGuard)
  async changePassword(@Req() req: any, @Body() changePasswordDto: any) {
    return this.authService.changePassword(
      req.user.userId,
      changePasswordDto.currentPassword,
      changePasswordDto.newPassword
    );
  }

}