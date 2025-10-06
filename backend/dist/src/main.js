"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const common_1 = require("@nestjs/common");
const app_module_1 = require("./app.module");
const helmet_1 = __importDefault(require("helmet"));
const config_1 = require("@nestjs/config");
const all_exceptions_filter_1 = require("./all-exceptions.filter");
async function bootstrap() {
    const logger = new common_1.Logger('Bootstrap');
    const app = await core_1.NestFactory.create(app_module_1.AppModule, { logger });
    const configService = app.get(config_1.ConfigService);
    const port = configService.get('PORT', 3001);
    const frontendUrl = configService.get('FRONTEND_URL', 'http://localhost:3000');
    app.use((0, helmet_1.default)());
    app.enableCors({
        origin: (origin, callback) => {
            const allowedOrigins = [frontendUrl, 'https://your-production-frontend.com'];
            if (!origin || allowedOrigins.includes(origin)) {
                callback(null, true);
            }
            else {
                callback(new Error('Not allowed by CORS'));
            }
        },
        credentials: true,
    });
    app.useGlobalPipes(new common_1.ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
    }));
    app.useGlobalFilters(new all_exceptions_filter_1.AllExceptionsFilter());
    app.setGlobalPrefix('api/v1');
    app.enableShutdownHooks();
    await app.listen(port, '0.0.0.0', () => {
        logger.log(`Server running on http://0.0.0.0:${port}/api/v1`);
    });
}
bootstrap();
//# sourceMappingURL=main.js.map