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
const bcrypt = __importStar(require("bcryptjs"));
const mongoose = __importStar(require("mongoose"));
async function bootstrap() {
    console.log('🌱 Starting DevKazi database seeding...');
    try {
        const app = await core_1.NestFactory.createApplicationContext(app_module_1.AppModule);
        if (mongoose.connection.readyState !== 1) {
            console.log('⏳ Waiting for database connection...');
            await new Promise((resolve, reject) => {
                mongoose.connection.on('connected', resolve);
                mongoose.connection.on('error', reject);
                setTimeout(() => reject(new Error('Database connection timeout')), 10000);
            });
        }
        console.log('✅ Database connected, starting seeding...');
        const usersCollection = mongoose.connection.collection('users');
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
        const result = await usersCollection.insertMany(sampleUsers);
        console.log('✅ Sample users created:', result.insertedCount);
        const teamsCollection = mongoose.connection.collection('teams');
        const sampleTeams = [
            {
                name: 'WebDev Warriors',
                description: 'Building modern web applications with cutting-edge tech',
                owner: result.insertedIds[0],
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
    }
    catch (error) {
        console.error('❌ Seeding failed:', error);
        process.exit(1);
    }
}
bootstrap();
//# sourceMappingURL=working-seed.js.map