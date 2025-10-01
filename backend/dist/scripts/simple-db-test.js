"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const app_module_1 = require("../src/app.module");
async function bootstrap() {
    console.log('🔗 Testing MongoDB Atlas connection...');
    try {
        const app = await core_1.NestFactory.createApplicationContext(app_module_1.AppModule);
        console.log('✅ SUCCESS: NestJS app started - MongoDB connection is working!');
        console.log('✅ Database connection to MongoDB Atlas is active');
        const connection = await app.resolve('DatabaseConnection');
        console.log('✅ Database services are available');
        await app.close();
        console.log('🎉 All tests passed!');
        process.exit(0);
    }
    catch (error) {
        console.error('❌ FAILED:', error.message);
        process.exit(1);
    }
}
bootstrap();
//# sourceMappingURL=simple-db-test.js.map