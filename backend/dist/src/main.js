"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
require("reflect-metadata");
const core_1 = require("@nestjs/core");
const common_1 = require("@nestjs/common");
const app_module_1 = require("./app.module");
const helmet_1 = __importDefault(require("helmet"));
const config_1 = require("@nestjs/config");
const all_exceptions_filter_1 = require("./all-exceptions.filter");
const swagger_1 = require("@nestjs/swagger");
async function bootstrap() {
    const logger = new common_1.Logger('Bootstrap');
    const app = await core_1.NestFactory.create(app_module_1.AppModule, { logger });
    const configService = app.get(config_1.ConfigService);
    const port = configService.get('PORT', 3001);
    const frontendUrl = configService.get('FRONTEND_URL', 'http://localhost:3000');
    const nodeEnv = configService.get('NODE_ENV', 'development');
    const requiredEnvVars = ['MONGODB_URI', 'JWT_SECRET', 'JWT_REFRESH_SECRET', 'GOOGLE_WEB_CLIENT_ID'];
    requiredEnvVars.forEach(varName => {
        if (!configService.get(varName)) {
            throw new Error(`Missing required environment variable: ${varName}`);
        }
    });
    app.use((0, helmet_1.default)());
    app.enableCors({
        origin: [frontendUrl, 'http://localhost:3000'],
        credentials: true,
        methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
        allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
    });
    app.useGlobalPipes(new common_1.ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
        disableErrorMessages: nodeEnv === 'production',
    }));
    app.useGlobalFilters(new all_exceptions_filter_1.AllExceptionsFilter());
    if (nodeEnv !== 'production') {
        const config = new swagger_1.DocumentBuilder()
            .setTitle('DevKazi API')
            .setDescription('Minimal team collaboration platform API')
            .setVersion('1.0')
            .addBearerAuth()
            .build();
        const document = swagger_1.SwaggerModule.createDocument(app, config);
        swagger_1.SwaggerModule.setup('api/docs', app, document);
        logger.log(`Swagger docs available at http://localhost:${port}/api/docs`);
    }
    app.setGlobalPrefix('api/v1');
    app.enableShutdownHooks();
    await app.listen(port, '0.0.0.0', () => {
        logger.log(`🚀 Server running on http://0.0.0.0:${port}/api/v1`);
        logger.log(`🌍 Environment: ${nodeEnv}`);
        logger.log(`🔗 Frontend URL: ${frontendUrl}`);
    });
}
bootstrap();
//# sourceMappingURL=main.js.map