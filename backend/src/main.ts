import { NestFactory } from '@nestjs/core';
import { Logger, ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import helmet from 'helmet';
import { ConfigService } from '@nestjs/config';
import { AllExceptionsFilter } from './all-exceptions.filter'; // Assume you created this

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create(AppModule, { logger });

  // Config service
  const configService = app.get(ConfigService);
  const port = configService.get<number>('PORT', 3001); // Backend on 3001
  const frontendUrl = configService.get<string>('FRONTEND_URL', 'http://localhost:3000');

  // Security middleware
  app.use(helmet());
  app.enableCors({
    origin: (origin, callback) => {
      const allowedOrigins = [frontendUrl, 'https://your-production-frontend.com'];
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    },
    credentials: true,
  });

  // Global validation
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));

  // Global exception filter
  app.useGlobalFilters(new AllExceptionsFilter());

  // Global prefix
  app.setGlobalPrefix('api/v1');

  // Enable shutdown hooks
  app.enableShutdownHooks();

  await app.listen(port, '0.0.0.0', () => {
    logger.log(`Server running on http://0.0.0.0:${port}/api/v1`);
  });
}
bootstrap();