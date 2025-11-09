import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { Logger, ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import helmet from 'helmet';
import { ConfigService } from '@nestjs/config';
import { AllExceptionsFilter } from './all-exceptions.filter';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { Request, Response } from 'express';
import { NestExpressApplication } from '@nestjs/platform-express';
import mongoose from 'mongoose';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create<NestExpressApplication>(AppModule, { logger });

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

  // Handle favicon.ico requests
  app.use((req: Request, res: Response, next) => {
    if (req.originalUrl === '/favicon.ico') {
      res.status(204).end();
    } else {
      next();
    }
  });

  // Security middleware
  app.use(helmet());

  // CORS configuration
  app.enableCors({
    origin: true,
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
    logger.log(`Server running on http://0.0.0.0:${port}/api/v1`);
    logger.log(`Environment: ${nodeEnv}`);
    logger.log(`Frontend URL: ${frontendUrl}`);

    // SAFELY log all registered routes
    try {
      const server = app.getHttpServer();
      const router = (server as any)._events?.request?._router;

      if (router && router.stack) {
        logger.log('Registered routes:');
        router.stack.forEach((layer: any) => {
          if (layer.route) {
            const methods = Object.keys(layer.route.methods).map(m => m.toUpperCase()).join(', ');
            const path = layer.route.path;
            logger.log(`  ${methods} ${path}`);
          }
        });
      } else {
        logger.warn('Could not read router stack. Routes may not be registered yet.');
      }
    } catch (error) {
      logger.error('Failed to log routes:', error);
    }
  });
}
mongoose.connect(process.env.MONGODB_URI, {
  bufferCommands: false,
  maxPoolSize: 10,
  serverSelectionTimeoutMS: 5000,
});

bootstrap().catch(err => {
  console.error('Bootstrap failed:', err);
  process.exit(1);
});