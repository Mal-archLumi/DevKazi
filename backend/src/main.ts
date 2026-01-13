// main.ts - UPDATED WITH ENHANCED CORS
import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { Logger, ValidationPipe, BadRequestException } from '@nestjs/common';
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
  const app = await NestFactory.create<NestExpressApplication>(AppModule, { 
    logger: ['error', 'warn', 'log', 'debug', 'verbose'] // ✅ Enhanced logging
  });

  const configService = app.get(ConfigService);
  const port = configService.get<number>('PORT', 3001);
  const frontendUrl = configService.get<string>('FRONTEND_URL', 'http://localhost:3000');
  const nodeEnv = configService.get<string>('NODE_ENV', 'production');

  // Validate required environment variables
  const requiredEnvVars = ['MONGODB_URI', 'JWT_SECRET', 'JWT_REFRESH_SECRET', 'GOOGLE_WEB_CLIENT_ID'];
  requiredEnvVars.forEach(varName => {
    if (!configService.get(varName)) {
      throw new Error(`Missing required environment variable: ${varName}`);
    }
  });

  // Handle favicon
  app.use((req: Request, res: Response, next) => {
    if (req.originalUrl === '/favicon.ico') {
      res.status(204).end();
    } else {
      next();
    }
  });

  // Security
  app.use(helmet());

  // ✅ ENHANCED CORS CONFIGURATION
  const allowedOrigins = [
    'http://localhost:3000',
    'http://localhost:3001',
    'http://127.0.0.1:3000',
    'http://127.0.0.1:3001',
    frontendUrl
  ].filter(Boolean); // Remove any falsy values

  // Remove duplicates
  const uniqueOrigins = [...new Set(allowedOrigins)];
  
  console.log('🌐 CORS Allowed Origins:', uniqueOrigins);

  app.enableCors({
    origin: (origin, callback) => {
      // Allow requests with no origin (like mobile apps, curl, postman)
      if (!origin) {
        return callback(null, true);
      }

      // Check if origin is allowed
      if (uniqueOrigins.indexOf(origin) !== -1) {
        return callback(null, true);
      }

      // In development, allow all origins for easier debugging
      if (nodeEnv === 'development') {
        console.log(`🌐 Development: Allowing origin ${origin}`);
        return callback(null, true);
      }

      console.warn(`🌐 CORS Blocked: ${origin}`);
      return callback(new Error('Not allowed by CORS'), false);
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS', 'HEAD'],
    allowedHeaders: [
      'Content-Type',
      'Authorization',
      'Accept',
      'Origin',
      'X-Requested-With',
      'X-Request-ID',
      'X-CSRF-Token'
    ],
    exposedHeaders: [
      'Content-Range',
      'X-Content-Range',
      'X-Total-Count',
      'X-Request-ID'
    ],
    maxAge: 86400, // 24 hours
    preflightContinue: false,
    optionsSuccessStatus: 204
  });

  // Add CORS logging middleware
  app.use((req: Request, res: Response, next) => {
    const origin = req.headers.origin;
    const method = req.method;
    const path = req.path;
    
    if (method === 'OPTIONS') {
      console.log(`🌐 CORS Preflight: ${method} ${path} from ${origin || 'no origin'}`);
    } else {
      console.log(`🌐 CORS Request: ${method} ${path} from ${origin || 'no origin'}`);
    }
    
    next();
  });

  // Validation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
      exceptionFactory: (errors) => {
        const messages = errors.map(error => {
          const constraints = error.constraints 
            ? Object.values(error.constraints).join(', ')
            : 'Unknown validation error';
          return `${error.property}: ${constraints}`;
        });
        
        console.error('🔴 Validation Error:', messages);
        
        return new BadRequestException({
          statusCode: 400,
          message: 'Validation failed',
          errors: messages,
        });
      },
    }),
  );

  // Global exception filter
  app.useGlobalFilters(new AllExceptionsFilter());

  // Swagger
  if (nodeEnv !== 'production') {
    const config = new DocumentBuilder()
      .setTitle('DevKazi API')
      .setDescription('Team collaboration platform API')
      .setVersion('1.0')
      .addBearerAuth()
      .build();
    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document);
    logger.log(`📚 Swagger docs: http://localhost:${port}/api/docs`);
  }

  // Global prefix
  app.setGlobalPrefix('api/v1');

  // Enable shutdown hooks
  app.enableShutdownHooks();

  await app.listen(port, '0.0.0.0', () => {
    logger.log(`🚀 Server running on http://0.0.0.0:${port}/api/v1`);
    logger.log(`🌍 Environment: ${nodeEnv}`);
    logger.log(`🔗 Frontend URL: ${frontendUrl}`);

    // ✅ IMPROVED ROUTE LOGGING
    setTimeout(() => {
      try {
        const server = app.getHttpServer();
        const router = (server as any)._events?.request?._router;

        if (router && router.stack) {
          logger.log('📋 Registered routes:');
          
          const routes: string[] = [];
          router.stack.forEach((layer: any) => {
            if (layer.route) {
              const methods = Object.keys(layer.route.methods)
                .map(m => m.toUpperCase())
                .join(', ');
              const path = `/api/v1${layer.route.path}`;
              routes.push(`  ${methods.padEnd(6)} ${path}`);
            }
          });

          // Sort and log routes
          routes.sort().forEach(route => logger.log(route));

          // ✅ Check for admin routes
          const adminRoutes = routes.filter(r => r.includes('/admin/'));
          if (adminRoutes.length === 0) {
            logger.error('⚠️  WARNING: No admin routes found!');
          } else {
            logger.log(`✅ Found ${adminRoutes.length} admin routes`);
            // Log admin routes specifically
            adminRoutes.forEach(route => logger.log(`  👑 ${route}`));
          }
        } else {
          logger.warn('⚠️  Could not read router stack');
        }
      } catch (error) {
        logger.error('❌ Failed to log routes:', error);
      }
    }, 1000); // Delay to ensure routes are registered
  });
}

// MongoDB connection
mongoose.connect(process.env.MONGODB_URI, {
  bufferCommands: false,
  maxPoolSize: 10,
  serverSelectionTimeoutMS: 5000,
}).then(() => {
  console.log('✅ MongoDB connected successfully');
}).catch(err => {
  console.error('❌ MongoDB connection failed:', err);
});

bootstrap().catch(err => {
  console.error('❌ Bootstrap failed:', err);
  process.exit(1);
});