import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { UsersService } from '../src/modules/users/users.service';
import { TeamsService } from '../src/modules/teams/teams.service';
import { getModelToken } from '@nestjs/mongoose';
import { User } from '../src/modules/users/schemas/user.schema';
import { Team } from '../src/modules/teams/schemas/team.schema';
import * as bcrypt from 'bcryptjs';

async function bootstrap() {
  console.log('🚀 Starting DevKazi database seeding...');
  
  const app = await NestFactory.createApplicationContext(AppModule);
  
  try {
    const userModel = app.get(getModelToken(User.name));
    const teamModel = app.get(getModelToken(Team.name));

    await new Promise(resolve => setTimeout(resolve, 2000));

    console.log('📝 Seeding sample data...');

    // Clear existing data (optional - be careful in production!)
    console.log('📝 Seeding sample data...');

    // Get service instances
    const usersService = app.get(UsersService);
    const teamsService = app.get(TeamsService);
    
    // Create sample users
    const hashedPassword = await bcrypt.hash('password123', 12);
    
    const users = await userModel.insertMany([
      {
        email: 'alice@student.com',
        password: hashedPassword,
        name: 'Alice Johnson',
        skills: ['React', 'Node.js', 'TypeScript', 'UI/UX'],
        bio: 'Frontend developer passionate about creating beautiful user experiences',
        education: 'Computer Science at University Tech',
        roles: ['student'],
        isVerified: true
      },
      {
        email: 'bob@student.com',
        password: hashedPassword,
        name: 'Bob Smith',
        skills: ['Python', 'Data Science', 'Machine Learning', 'SQL'],
        bio: 'Data science enthusiast with interest in AI and analytics',
        education: 'Data Science at State University',
        roles: ['student'],
        isVerified: true
      }
    ]);

    console.log('✅ Sample users created:', users.map(u => u.name));


    // Create sample teams
    const teams = await teamModel.insertMany([
      {
        name: 'WebDev Warriors',
        description: 'Building modern web applications with cutting-edge tech',
        owner: users[0]._id,
        members: [{
          userId: users[0]._id,
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
        status: 'active'
      }
    ]);

    console.log('✅ Sample teams created:', teams.map(t => t.name));




    console.log('🎉 Database seeding completed successfully!');
    console.log('📧 Test user emails: alice@student.com, bob@student.com');
    console.log('🔑 Password for all: password123');

  } catch (error) {
    console.error('❌ Seeding failed:', error);
  } finally {
    await app.close();
    process.exit(0);
  }
}

bootstrap();