import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { getConnectionToken } from '@nestjs/mongoose';
import * as bcrypt from 'bcryptjs';

async function bootstrap() {
  console.log('🌱 Starting DevKazi database seeding...');
  
  let app;
  
  try {
    // Create the NestJS application context
    app = await NestFactory.createApplicationContext(AppModule);
    
    console.log('✅ NestJS application initialized');
    
    // Get the Mongoose connection properly using NestJS dependency injection
    const connection = app.get(getConnectionToken());
    
    console.log('🔍 Checking database connection...');
    
    // Wait for connection to be established
    if (connection.readyState !== 1) {
      console.log('⏳ Waiting for database connection...');
      
      // Create a promise that resolves when connected
      await new Promise((resolve, reject) => {
        const timeout = setTimeout(() => {
          reject(new Error('Database connection timeout after 10 seconds'));
        }, 10000);
        
        connection.on('connected', () => {
          clearTimeout(timeout);
          resolve(true);
        });
        
        connection.on('error', (error) => {
          clearTimeout(timeout);
          reject(error);
        });
      });
    }
    
    console.log('✅ Database connected successfully!');
    console.log('📊 Starting data seeding...');
    
    // Get collections
    const db = connection.db;
    const usersCollection = db.collection('users');
    const teamsCollection = db.collection('teams');
    const postsCollection = db.collection('posts');
    
    // Clear existing data (optional - remove if you want to keep existing data)
    console.log('🧹 Clearing existing data...');
    await usersCollection.deleteMany({});
    await teamsCollection.deleteMany({});
    await postsCollection.deleteMany({});
    
    // Create sample users
    const hashedPassword = await bcrypt.hash('password123', 12);
    
    console.log('👥 Creating sample users...');
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
      },
      {
        email: 'charlie@mentor.com',
        password: hashedPassword,
        name: 'Charlie Brown',
        skills: ['Project Management', 'Agile', 'Mentoring'],
        bio: 'Experienced tech mentor helping students grow',
        education: 'Senior Developer at TechCorp',
        roles: ['mentor'],
        isVerified: true,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ];
    
    const usersResult = await usersCollection.insertMany(sampleUsers);
    console.log(`✅ Created ${usersResult.insertedCount} users`);
    
    // Create sample teams
    console.log('👥 Creating sample teams...');
    const sampleTeams = [
      {
        name: 'WebDev Warriors',
        description: 'Building modern web applications with cutting-edge tech',
        ownerId: usersResult.insertedIds[0], // Alice's ID
        members: [
          {
            userId: usersResult.insertedIds[0],
            role: 'Team Lead',
            joinedAt: new Date(),
            skills: ['React', 'Node.js', 'TypeScript']
          }
        ],
        requiredRoles: [
          { 
            role: 'Frontend Developer', 
            slots: 2, 
            skills: ['React', 'JavaScript', 'CSS'], 
            filled: 1 
          },
          { 
            role: 'Backend Developer', 
            slots: 1, 
            skills: ['Node.js', 'MongoDB', 'Express'], 
            filled: 0 
          }
        ],
        projectName: 'E-commerce Platform',
        projectDescription: 'Building a full-stack e-commerce solution with modern technologies',
        techStack: ['React', 'Node.js', 'MongoDB', 'Express', 'TypeScript'],
        duration: '8 weeks',
        status: 'recruiting',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        name: 'Data Science Squad',
        description: 'Exploring data and building ML models',
        ownerId: usersResult.insertedIds[1], // Bob's ID
        members: [
          {
            userId: usersResult.insertedIds[1],
            role: 'Data Lead',
            joinedAt: new Date(),
            skills: ['Python', 'Machine Learning', 'Data Analysis']
          }
        ],
        requiredRoles: [
          { 
            role: 'ML Engineer', 
            slots: 1, 
            skills: ['Python', 'TensorFlow', 'Scikit-learn'], 
            filled: 0 
          },
          { 
            role: 'Data Analyst', 
            slots: 1, 
            skills: ['SQL', 'Pandas', 'Visualization'], 
            filled: 0 
          }
        ],
        projectName: 'Predictive Analytics Dashboard',
        projectDescription: 'Creating a dashboard for predictive business analytics',
        techStack: ['Python', 'FastAPI', 'React', 'PostgreSQL', 'Docker'],
        duration: '6 weeks',
        status: 'recruiting',
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ];
    
    const teamsResult = await teamsCollection.insertMany(sampleTeams);
    console.log(`✅ Created ${teamsResult.insertedCount} teams`);
    
    // Create sample internship posts
    console.log('📝 Creating sample internship posts...');
    const samplePosts = [
      {
        title: 'Full-Stack E-commerce Development',
        type: 'internship',
        description: 'Join our team to build a modern e-commerce platform from scratch. Great opportunity to learn full-stack development in a real-world scenario.',
        company: 'TechStart Inc.',
        duration: '8 weeks',
        teamId: teamsResult.insertedIds[0],
        requiredSkills: ['React', 'Node.js', 'MongoDB', 'TypeScript'],
        roles: [
          { role: 'Frontend Developer', slots: 2, filled: 1 },
          { role: 'Backend Developer', slots: 1, filled: 0 }
        ],
        deadline: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days from now
        status: 'active',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        title: 'Machine Learning Internship for Data Enthusiasts',
        type: 'internship',
        description: 'Work on real ML projects and gain hands-on experience with data preprocessing, model training, and deployment.',
        company: 'DataCorp Analytics',
        duration: '6 weeks',
        teamId: teamsResult.insertedIds[1],
        requiredSkills: ['Python', 'Machine Learning', 'Data Analysis'],
        roles: [
          { role: 'ML Engineer', slots: 1, filled: 0 },
          { role: 'Data Analyst', slots: 1, filled: 0 }
        ],
        deadline: new Date(Date.now() + 21 * 24 * 60 * 60 * 1000), // 21 days from now
        status: 'active',
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ];
    
    const postsResult = await postsCollection.insertMany(samplePosts);
    console.log(`✅ Created ${postsResult.insertedCount} internship posts`);
    
    console.log('\n🎉 Database seeding completed successfully!');
    console.log('==========================================');
    console.log('📧 Test Credentials:');
    console.log('   Student: alice@student.com / password123');
    console.log('   Student: bob@student.com / password123');
    console.log('   Mentor:  charlie@mentor.com / password123');
    console.log('==========================================\n');
    
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  } finally {
    if (app) {
      await app.close();
    }
  }
}

bootstrap();