"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const throttler_1 = require("@nestjs/throttler");
const core_1 = require("@nestjs/core");
const mongoose_1 = require("@nestjs/mongoose");
const mailer_1 = require("@nestjs-modules/mailer");
const auth_module_1 = require("./auth/auth.module");
const users_module_1 = require("./modules/users/users.module");
const teams_module_1 = require("./modules/teams/teams.module");
const chat_module_1 = require("./modules/chat/chat.module");
const app_controller_1 = require("./app.controller");
const app_service_1 = require("./app.service");
const custom_throttler_guard_1 = require("./common/guards/custom-throttler.guard");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({
                isGlobal: true,
                envFilePath: '.env',
            }),
            throttler_1.ThrottlerModule.forRoot([
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
            mongoose_1.MongooseModule.forRoot(process.env.MONGODB_URI || 'mongodb://localhost:27017/devkazi', {
                connectionFactory: (connection) => {
                    connection.on('connected', () => {
                        console.log('MongoDB connected successfully');
                    });
                    connection.on('error', (error) => {
                        console.error('MongoDB connection error:', error);
                    });
                    connection.on('disconnected', () => {
                        console.log('MongoDB disconnected');
                    });
                    return connection;
                },
                connectTimeoutMS: 10000,
                socketTimeoutMS: 45000,
                maxPoolSize: 10,
                minPoolSize: 5,
                retryAttempts: 3,
                retryDelay: 1000,
            }),
            mailer_1.MailerModule.forRootAsync({
                imports: [config_1.ConfigModule],
                inject: [config_1.ConfigService],
                useFactory: (config) => ({
                    transport: {
                        host: config.get('SMTP_HOST'),
                        port: config.get('SMTP_PORT') || 587,
                        secure: config.get('SMTP_PORT') === 465,
                        auth: {
                            user: config.get('SMTP_USER'),
                            pass: config.get('SMTP_PASS'),
                        },
                        tls: {
                            rejectUnauthorized: config.get('NODE_ENV') === 'production',
                        },
                    },
                    defaults: {
                        from: config.get('MAIL_FROM') || '"DevKazi" <no-reply@devkazi.com>',
                    },
                }),
            }),
            auth_module_1.AuthModule,
            users_module_1.UsersModule,
            teams_module_1.TeamsModule,
            chat_module_1.ChatModule,
        ],
        controllers: [app_controller_1.AppController],
        providers: [
            app_service_1.AppService,
            {
                provide: core_1.APP_GUARD,
                useClass: custom_throttler_guard_1.CustomThrottlerGuard,
            },
        ],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map