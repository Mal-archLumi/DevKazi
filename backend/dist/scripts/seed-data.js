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
const users_service_1 = require("../src/modules/users/users.service");
const teams_service_1 = require("../src/modules/teams/teams.service");
const posts_service_1 = require("../src/modules/posts/posts.service");
const bcrypt = __importStar(require("bcryptjs"));
async function bootstrap() {
    console.log('🚀 Starting DevKazi database seeding...');
    const app = await core_1.NestFactory.createApplicationContext(app_module_1.AppModule);
    try {
        const usersService = app.get(users_service_1.UsersService);
        const teamsService = app.get(teams_service_1.TeamsService);
        const postsService = app.get(posts_service_1.PostsService);
        console.log('📝 Seeding sample data...');
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
                deadline: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
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
                deadline: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000),
                status: 'active',
                projectName: 'Customer Analytics Dashboard'
            })
        ]);
        console.log('✅ Sample posts created:', posts.map(p => p.title));
        console.log('🎉 Database seeding completed successfully!');
        console.log('📧 Test user emails: alice@student.com, bob@student.com, charlie@student.com');
        console.log('🔑 Password for all: password123');
    }
    catch (error) {
        console.error('❌ Seeding failed:', error);
        throw error;
    }
    finally {
        await app.close();
        process.exit(0);
    }
}
bootstrap().catch(err => {
    console.error('💥 Seeding failed:', err);
    process.exit(1);
});
//# sourceMappingURL=seed-data.js.map