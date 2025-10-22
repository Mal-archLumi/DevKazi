import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { Logger, ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import helmet from 'helmet';
import { ConfigService } from '@nestjs/config';
import { AllExceptionsFilter } from './all-exceptions.filter';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create(AppModule, { logger });

  // Config service
  const configService = app.get(ConfigService);
  const port = configService.get<number>('PORT', 3001);
  const frontendUrl = configService.get<string>('FRONTEND_URL', 'http://localhost:3000');
  const nodeEnv = configService.get<string>('NODE_ENV', 'development');

  // Validate required environment variables
  const requiredEnvVars = ['MONGODB_URI', 'JWT_SECRET', 'JWT_REFRESH_SECRET', 'GOOGLE_WEB_CLIENT_ID'];
  requiredEnvVars.forEach(varName => {
    if (!configService.get(varName)) {
      throw new Error(`Missing required environment variable: ${varName}`);
    }
  });

  // Security middleware
  app.use(helmet());
  
  // CORS configuration
  app.enableCors({
    origin: [frontendUrl, 'http://localhost:3000'],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  });

  // Global validation
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
    disableErrorMessages: nodeEnv === 'production',
  }));

  // Global exception filter
  app.useGlobalFilters(new AllExceptionsFilter());

  // Swagger documentation (only in development)
  if (nodeEnv !== 'production') {
    const config = new DocumentBuilder()
      .setTitle('DevKazi API')
      .setDescription('Minimal team collaboration platform API')
      .setVersion('1.0')
      .addBearerAuth()
      .build();
    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document);
    logger.log(`Swagger docs available at http://localhost:${port}/api/docs`);
  }

  // Global prefix
  app.setGlobalPrefix('api/v1');

  // Enable shutdown hooks
  app.enableShutdownHooks();

  await app.listen(port, '0.0.0.0', () => {
    logger.log(`🚀 Server running on http://0.0.0.0:${port}/api/v1`);
    logger.log(`🌍 Environment: ${nodeEnv}`);
    logger.log(`🔗 Frontend URL: ${frontendUrl}`);
  });
}
bootstrap();