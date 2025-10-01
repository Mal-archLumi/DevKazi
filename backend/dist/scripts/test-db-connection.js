"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const app_module_1 = require("../src/app.module");
async function bootstrap() {
    console.log('🔗 Testing MongoDB Atlas connection...');
    const app = await core_1.NestFactory.createApplicationContext(app_module_1.AppModule);
    try {
        const connection = app.get('DATABASE_CONNECTION');
        const db = connection.db;
        const adminDb = db.admin();
        const pingResult = await adminDb.ping();
        console.log('✅ MongoDB Ping:', pingResult);
        const collections = await db.listCollections().toArray();
        console.log('📊 Collections found:', collections.map(c => c.name));
        const usersCount = await db.collection('users').countDocuments();
        console.log('👥 Users in database:', usersCount);
        if (usersCount > 0) {
            const users = await db.collection('users').find().limit(3).toArray();
            console.log('Sample users:', users.map(u => ({ email: u.email, name: u.name })));
        }
        else {
            console.log('❌ No users found in database. Need to run seed script.');
        }
    }
    catch (error) {
        console.error('❌ Database connection failed:', error.message);
    }
    finally {
        await app.close();
        process.exit(0);
    }
}
bootstrap();
//# sourceMappingURL=test-db-connection.js.map