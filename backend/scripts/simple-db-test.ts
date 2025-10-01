import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';

async function bootstrap() {
  console.log('🔗 Testing MongoDB Atlas connection...');
  
  try {
    // Just creating the app context tests the connection
    const app = await NestFactory.createApplicationContext(AppModule);
    
    console.log('✅ SUCCESS: NestJS app started - MongoDB connection is working!');
    console.log('✅ Database connection to MongoDB Atlas is active');
    
    // Simple test - try to access a basic service
    const connection = await app.resolve('DatabaseConnection');
    console.log('✅ Database services are available');
    
    await app.close();
    console.log('🎉 All tests passed!');
    process.exit(0);
  } catch (error) {
    console.error('❌ FAILED:', error.message);
    process.exit(1);
  }
}

bootstrap();