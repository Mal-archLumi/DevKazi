import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import * as bcrypt from 'bcryptjs';
import * as mongoose from 'mongoose';

async function bootstrap() {
  console.log('🌱 Starting DevKazi database seeding...');
  
  try {
    const app = await NestFactory.createApplicationContext(AppModule);
    
    // Simple connection check - if mongoose is connected, proceed
    if (mongoose.connection.readyState !== 1) {
      console.log('⏳ Waiting for database connection...');
      // Wait for connection event
      await new Promise((resolve, reject) => {
        mongoose.connection.on('connected', resolve);
        mongoose.connection.on('error', reject);
        
        // Timeout after 10 seconds
        setTimeout(() => reject(new Error('Database connection timeout')), 10000);
      });
    }
    
    console.log('✅ Database connected, starting seeding...');
    
    // Rest of your seeding code remains the same...
    const usersCollection = mongoose.connection.collection('users');
    
    // Check if users already exist
    const existingUsers = await usersCollection.countDocuments();
    if (existingUsers > 0) {
      console.log(`📊 ${existingUsers} users already exist in database`);
      console.log('Showing existing users:');
      const users = await usersCollection.find().limit(5).toArray();
      users.forEach(user => {
        console.log(`   - ${user.email} (${user.name})`);
      });
      await app.close();
      process.exit(0);
    }
    
    // Create sample users
    const hashedPassword = await bcrypt.hash('password123', 12);
    
    const sampleUsers = [
      {
        email: 'alice@student.com',
        password: hashedPassword,
        name: 'Alice Johnson',
        skills: ['React', 'Node.js', 'TypeScript', 'UI/UX'],
        bio: 'Frontend developer passionate about creating beautiful user experiences',
        education: 'Computer Science at University Tech',
        roles: ['student'],
        isVerified: true,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        email: 'bob@student.com',
        password: hashedPassword,
        name: 'Bob Smith',
        skills: ['Python', 'Data Science', 'Machine Learning', 'SQL'],
        bio: 'Data science enthusiast with interest in AI and analytics',
        education: 'Data Science at State University',
        roles: ['student'],
        isVerified: true,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ];
    
    // Insert users directly into the database
    const result = await usersCollection.insertMany(sampleUsers);
    console.log('✅ Sample users created:', result.insertedCount);
    
    // Create sample teams
    const teamsCollection = mongoose.connection.collection('teams');
    const sampleTeams = [
      {
        name: 'WebDev Warriors',
        description: 'Building modern web applications with cutting-edge tech',
        owner: result.insertedIds[0], // Alice's ID
        members: [{
          userId: result.insertedIds[0],
          role: 'Team Lead',
          joinedAt: new Date()
        }],
        requiredRoles: [
          { role: 'Frontend Developer', slots: 2, skills: ['React', 'JavaScript'], filled: 1 },
          { role: 'Backend Developer', slots: 1, skills: ['Node.js', 'MongoDB'], filled: 0 }
        ],
        projectName: 'E-commerce Platform',
        projectDescription: 'Building a full-stack e-commerce solution',
        techStack: ['React', 'Node.js', 'MongoDB', 'Express'],
        duration: '8 weeks',
        status: 'active',
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ];
    
    const teamsResult = await teamsCollection.insertMany(sampleTeams);
    console.log('✅ Sample teams created:', teamsResult.insertedCount);
    
    console.log('🎉 Database seeding completed successfully!');
    console.log('📧 Test user emails: alice@student.com, bob@student.com');
    console.log('🔑 Password for all: password123');
    
    await app.close();
    process.exit(0);
    
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  }
}

bootstrap();