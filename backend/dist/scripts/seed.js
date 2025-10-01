"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const app_module_1 = require("../src/app.module");
const mongoose_1 = require("@nestjs/mongoose");
const bcrypt = __importStar(require("bcryptjs"));
async function bootstrap() {
    console.log('🌱 Starting DevKazi database seeding...');
    let app;
    try {
        app = await core_1.NestFactory.createApplicationContext(app_module_1.AppModule);
        console.log('✅ NestJS application initialized');
        const connection = app.get((0, mongoose_1.getConnectionToken)());
        console.log('🔍 Checking database connection...');
        if (connection.readyState !== 1) {
            console.log('⏳ Waiting for database connection...');
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
        const db = connection.db;
        const usersCollection = db.collection('users');
        const teamsCollection = db.collection('teams');
        const postsCollection = db.collection('posts');
        console.log('🧹 Clearing existing data...');
        await usersCollection.deleteMany({});
        await teamsCollection.deleteMany({});
        await postsCollection.deleteMany({});
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
        console.log('👥 Creating sample teams...');
        const sampleTeams = [
            {
                name: 'WebDev Warriors',
                description: 'Building modern web applications with cutting-edge tech',
                ownerId: usersResult.insertedIds[0],
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
                ownerId: usersResult.insertedIds[1],
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
                deadline: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
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
                deadline: new Date(Date.now() + 21 * 24 * 60 * 60 * 1000),
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
    }
    catch (error) {
        console.error('❌ Seeding failed:', error);
        process.exit(1);
    }
    finally {
        if (app) {
            await app.close();
        }
    }
}
bootstrap();
//# sourceMappingURL=seed.js.map