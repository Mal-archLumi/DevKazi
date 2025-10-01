import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { MongooseModule } from '@nestjs/mongoose';

async function bootstrap() {
  console.log('🔗 Testing MongoDB Atlas connection...');
  
  const app = await NestFactory.createApplicationContext(AppModule);
  
  try {
    // Get the mongoose connection from the module
    const connection = app.get('DATABASE_CONNECTION');
    
    // Test connection
    const db = connection.db;
    const adminDb = db.admin();
    
    const pingResult = await adminDb.ping();
    console.log('✅ MongoDB Ping:', pingResult);
    
    // Check if database has any collections
    const collections = await db.listCollections().toArray();
    console.log('📊 Collections found:', collections.map(c => c.name));
    
    // Check if users collection exists and has data
    const usersCount = await db.collection('users').countDocuments();
    console.log('👥 Users in database:', usersCount);
    
    if (usersCount > 0) {
      const users = await db.collection('users').find().limit(3).toArray();
      console.log('Sample users:', users.map(u => ({ email: u.email, name: u.name })));
    } else {
      console.log('❌ No users found in database. Need to run seed script.');
    }
    
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
  } finally {
    await app.close();
    process.exit(0);
  }
}

bootstrap();