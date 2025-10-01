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
const mongoose_1 = require("@nestjs/mongoose");
const user_schema_1 = require("../src/modules/users/schemas/user.schema");
const post_schema_1 = require("../src/modules/posts/schemas/post.schema");
const team_schema_1 = require("../src/modules/teams/schemas/team.schema");
const bcrypt = __importStar(require("bcryptjs"));
async function bootstrap() {
    console.log('🚀 Starting DevKazi database seeding...');
    const app = await core_1.NestFactory.createApplicationContext(app_module_1.AppModule);
    try {
        const userModel = app.get((0, mongoose_1.getModelToken)(user_schema_1.User.name));
        const teamModel = app.get((0, mongoose_1.getModelToken)(team_schema_1.Team.name));
        const postModel = app.get((0, mongoose_1.getModelToken)(post_schema_1.Post.name));
        await new Promise(resolve => setTimeout(resolve, 2000));
        console.log('📝 Seeding sample data...');
        console.log('📝 Seeding sample data...');
        const usersService = app.get(users_service_1.UsersService);
        const teamsService = app.get(teams_service_1.TeamsService);
        const postsService = app.get(posts_service_1.PostsService);
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
        const posts = await postModel.insertMany([
            {
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
            }
        ]);
        console.log('✅ Sample posts created:', posts.map(p => p.title));
        console.log('🎉 Database seeding completed successfully!');
        console.log('📧 Test user emails: alice@student.com, bob@student.com');
        console.log('🔑 Password for all: password123');
    }
    catch (error) {
        console.error('❌ Seeding failed:', error);
    }
    finally {
        await app.close();
        process.exit(0);
    }
}
bootstrap();
//# sourceMappingURL=seed-data.js.map