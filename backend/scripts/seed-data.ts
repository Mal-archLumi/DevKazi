import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { UsersService } from '../src/modules/users/users.service';
import { TeamsService } from '../src/modules/teams/teams.service';
import { PostsService } from '../src/modules/posts/posts.service';
import * as bcrypt from 'bcryptjs';

async function bootstrap() {
  console.log('🚀 Starting DevKazi database seeding...');
  
  const app = await NestFactory.createApplicationContext(AppModule);
  
  try {
    const usersService = app.get(UsersService);
    const teamsService = app.get(TeamsService);
    const postsService = app.get(PostsService);

    // Clear existing data (optional - be careful in production!)
    console.log('📝 Seeding sample data...');

    // Create sample users
    const hashedPassword = await bcrypt.hash('password123', 12);
    
    const users = await Promise.all([
      usersService.create({
        email: 'alice@student.com',
        password: hashedPassword,
        name: 'Alice Johnson',
        skills: ['React', 'Node.js', 'TypeScript', 'UI/UX'],
        bio: 'Frontend developer passionate about creating beautiful user experiences',
        education: 'Computer Science at University Tech',
        roles: ['student']
      }),
      usersService.create({
        email: 'bob@student.com',
        password: hashedPassword,
        name: 'Bob Smith',
        skills: ['Python', 'Data Science', 'Machine Learning', 'SQL'],
        bio: 'Data science enthusiast with interest in AI and analytics',
        education: 'Data Science at State University',
        roles: ['student']
      }),
      usersService.create({
        email: 'charlie@student.com',
        password: hashedPassword,
        name: 'Charlie Brown',
        skills: ['Java', 'Spring Boot', 'AWS', 'Docker'],
        bio: 'Backend developer focused on scalable systems',
        education: 'Software Engineering at College Tech',
        roles: ['student']
      })
    ]);

    console.log('✅ Sample users created:', users.map(u => u.name));

    // Create sample teams
    const teams = await Promise.all([
      teamsService.create({
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
      }),
      teamsService.create({
        name: 'Data Crushers',
        description: 'Data science team tackling real-world problems',
        owner: users[1]._id,
        members: [{
          userId: users[1]._id,
          role: 'Data Scientist',
          joinedAt: new Date()
        }],
        requiredRoles: [
          { role: 'Data Analyst', slots: 1, skills: ['Python', 'Pandas'], filled: 0 },
          { role: 'ML Engineer', slots: 1, skills: ['TensorFlow', 'Scikit-learn'], filled: 0 }
        ],
        projectName: 'Predictive Analytics Dashboard',
        projectDescription: 'Creating ML models for business intelligence',
        techStack: ['Python', 'TensorFlow', 'React', 'FastAPI'],
        duration: '6 weeks',
        status: 'active'
      })
    ]);

    console.log('✅ Sample teams created:', teams.map(t => t.name));

    // Create sample internship posts
    const posts = await Promise.all([
      postsService.create({
        title: 'Full-Stack Development Internship',
        description: 'Join our team to build a real-world application from scratch',
        team: teams[0]._id,
        type: 'internship',
        roles: [
          { role: 'Frontend Developer', slots: 2, skills: ['React', 'TypeScript'], filled: 1 },
          { role: 'Backend Developer', slots: 1, skills: ['Node.js', 'Express'], filled: 0 }
        ],
        requiredSkills: ['JavaScript', 'Git', 'REST APIs'],
        duration: '8 weeks',
        deadline: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days from now
        status: 'active',
        projectName: 'Task Management App'
      }),
      postsService.create({
        title: 'Data Science Team Needed',
        description: 'Looking for data enthusiasts to analyze customer behavior',
        team: teams[1]._id,
        type: 'team-formation',
        roles: [
          { role: 'Data Analyst', slots: 1, skills: ['Python', 'SQL'], filled: 0 },
          { role: 'Visualization Expert', slots: 1, skills: ['Tableau', 'D3.js'], filled: 0 }
        ],
        requiredSkills: ['Python', 'Data Analysis', 'Statistics'],
        duration: '6 weeks',
        deadline: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000), // 14 days from now
        status: 'active',
        projectName: 'Customer Analytics Dashboard'
      })
    ]);

    console.log('✅ Sample posts created:', posts.map(p => p.title));

    console.log('🎉 Database seeding completed successfully!');
    console.log('📧 Test user emails: alice@student.com, bob@student.com, charlie@student.com');
    console.log('🔑 Password for all: password123');

  } catch (error) {
    console.error('❌ Seeding failed:', error);
    throw error;
  } finally {
    await app.close();
    process.exit(0);
  }
}

bootstrap().catch(err => {
  console.error('💥 Seeding failed:', err);
  process.exit(1);
});