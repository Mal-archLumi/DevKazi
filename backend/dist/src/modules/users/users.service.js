"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UsersService = void 0;
const common_1 = require("@nestjs/common");
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
const user_schema_1 = require("./schemas/user.schema");
const role_enum_1 = require("../../auth/enums/role.enum");
let UsersService = class UsersService {
    userModel;
    constructor(userModel) {
        this.userModel = userModel;
    }
    async findByEmail(email) {
        return this.userModel.findOne({ email: email.toLowerCase() });
    }
    async findById(id) {
        return this.userModel.findById(id);
    }
    async create(userData) {
        const user = new this.userModel(userData);
        return user.save();
    }
    async update(id, updateData) {
        return this.userModel.findByIdAndUpdate(id, updateData, { new: true });
    }
    async getProfile(userId) {
        const user = await this.userModel.findById(userId);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        return this.mapToUserResponseDto(user);
    }
    async getPublicProfile(userId) {
        const user = await this.userModel.findOne({
            _id: userId,
            $and: [
                {
                    $or: [
                        { isActive: true },
                        { isActive: { $exists: false } }
                    ]
                },
                {
                    $or: [
                        { isProfilePublic: true },
                        { isProfilePublic: { $exists: false } }
                    ]
                }
            ]
        });
        if (!user) {
            throw new common_1.NotFoundException('User not found or profile is private');
        }
        return this.mapToPublicUserResponseDto(user);
    }
    async updateProfile(userId, updateData) {
        const user = await this.userModel.findById(userId);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        if (updateData.role && user.roles && user.roles.length > 0 && updateData.role !== user.roles[0]) {
            throw new common_1.ForbiddenException('Cannot change role through profile update');
        }
        if (updateData.email && updateData.email !== user.email) {
            const existingUser = await this.userModel.findOne({ email: updateData.email.toLowerCase() });
            if (existingUser) {
                throw new common_1.BadRequestException('Email already exists');
            }
            updateData.email = updateData.email.toLowerCase();
        }
        const updatedUser = await this.userModel.findByIdAndUpdate(userId, { ...updateData, updatedAt: new Date() }, { new: true, runValidators: true });
        if (!updatedUser) {
            throw new common_1.NotFoundException('User not found during update');
        }
        return this.mapToUserResponseDto(updatedUser);
    }
    async deleteAccount(userId) {
        const user = await this.userModel.findById(userId);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        await this.userModel.findByIdAndUpdate(userId, {
            isActive: false,
            email: `deleted-${Date.now()}-${user.email}`,
            updatedAt: new Date(),
        });
    }
    async addSkills(userId, skills) {
        const user = await this.userModel.findById(userId);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        const validatedSkills = this.validateSkills(skills);
        const currentSkills = user.skills || [];
        const uniqueSkills = [...new Set([...currentSkills, ...validatedSkills])];
        const updatedUser = await this.userModel.findByIdAndUpdate(userId, { skills: uniqueSkills, updatedAt: new Date() }, { new: true });
        if (!updatedUser) {
            throw new common_1.NotFoundException('User not found during update');
        }
        return this.mapToUserResponseDto(updatedUser);
    }
    async removeSkills(userId, skills) {
        const user = await this.userModel.findById(userId);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        const currentSkills = user.skills || [];
        const updatedSkills = currentSkills.filter(skill => !skills.includes(skill));
        const updatedUser = await this.userModel.findByIdAndUpdate(userId, { skills: updatedSkills, updatedAt: new Date() }, { new: true });
        if (!updatedUser) {
            throw new common_1.NotFoundException('User not found during update');
        }
        return this.mapToUserResponseDto(updatedUser);
    }
    async searchUsers(searchDto) {
        const page = searchDto.page || 1;
        const limit = searchDto.limit || 10;
        const skip = (page - 1) * limit;
        const filter = {
            $and: [
                {
                    $or: [
                        { isActive: true },
                        { isActive: { $exists: false } }
                    ]
                },
                {
                    $or: [
                        { isProfilePublic: true },
                        { isProfilePublic: { $exists: false } }
                    ]
                }
            ]
        };
        if (searchDto.role)
            filter.role = searchDto.role;
        if (searchDto.verifiedOnly)
            filter.isVerified = true;
        if (searchDto.skills && searchDto.skills.length > 0) {
            filter.skills = { $in: searchDto.skills.map(skill => new RegExp(skill, 'i')) };
        }
        if (searchDto.query) {
            filter.$or = [
                { name: { $regex: searchDto.query, $options: 'i' } },
                { bio: { $regex: searchDto.query, $options: 'i' } },
                { education: { $regex: searchDto.query, $options: 'i' } },
                { skills: { $in: [new RegExp(searchDto.query, 'i')] } }
            ];
        }
        const [users, total] = await Promise.all([
            this.userModel
                .find(filter)
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(limit)
                .exec(),
            this.userModel.countDocuments(filter),
        ]);
        return {
            users: users.map(user => this.mapToPublicUserResponseDto(user)),
            total,
        };
    }
    async getMentors() {
        const mentors = await this.userModel.find({
            roles: role_enum_1.Role.MENTOR,
            $and: [
                {
                    $or: [
                        { isActive: true },
                        { isActive: { $exists: false } }
                    ]
                },
                {
                    $or: [
                        { isProfilePublic: true },
                        { isProfilePublic: { $exists: false } }
                    ]
                }
            ]
        });
        return mentors.map(mentor => this.mapToPublicUserResponseDto(mentor));
    }
    async getStudents() {
        const students = await this.userModel.find({
            roles: role_enum_1.Role.STUDENT,
            $and: [
                {
                    $or: [
                        { isActive: true },
                        { isActive: { $exists: false } }
                    ]
                },
                {
                    $or: [
                        { isProfilePublic: true },
                        { isProfilePublic: { $exists: false } }
                    ]
                }
            ]
        });
        return students.map(student => this.mapToPublicUserResponseDto(student));
    }
    async requestVerification(userId) {
        const user = await this.userModel.findById(userId);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        console.log(`Verification requested for user: ${user.email}`);
        return { message: 'Verification request submitted. An admin will review your profile.' };
    }
    validateSkills(skills) {
        const validSkills = [
            'JavaScript', 'TypeScript', 'Python', 'Java', 'C#', 'C++', 'Ruby', 'Go',
            'React', 'Angular', 'Vue', 'Node.js', 'Express', 'NestJS', 'Django', 'Spring',
            'MongoDB', 'PostgreSQL', 'MySQL', 'Redis', 'Docker', 'Kubernetes', 'AWS', 'Azure',
            'Git', 'REST API', 'GraphQL', 'Machine Learning', 'Data Science', 'DevOps'
        ];
        const validatedSkills = skills.filter(skill => validSkills.some(validSkill => validSkill.toLowerCase() === skill.trim().toLowerCase()));
        if (validatedSkills.length === 0) {
            throw new common_1.BadRequestException('No valid skills provided');
        }
        return validatedSkills.map(skill => validSkills.find(validSkill => validSkill.toLowerCase() === skill.trim().toLowerCase())).filter((skill) => skill !== undefined);
    }
    mapToUserResponseDto(user) {
        const userObj = user.toObject ? user.toObject() : user;
        return {
            _id: userObj._id?.toString() || '',
            email: userObj.email,
            name: userObj.name,
            role: (userObj.roles && userObj.roles.length > 0) ? userObj.roles[0] : role_enum_1.Role.STUDENT,
            bio: userObj.bio,
            education: userObj.education,
            skills: userObj.skills || [],
            avatar: userObj.avatar,
            isVerified: userObj.isVerified || false,
            isProfilePublic: userObj.isProfilePublic !== undefined ? userObj.isProfilePublic : true,
            company: userObj.company,
            position: userObj.position,
            github: userObj.github,
            linkedin: userObj.linkedin,
            portfolio: userObj.portfolio,
            experienceYears: userObj.experienceYears || 0,
            createdAt: userObj.createdAt || new Date(),
            updatedAt: userObj.updatedAt || new Date(),
        };
    }
    mapToPublicUserResponseDto(user) {
        const userObj = user.toObject ? user.toObject() : user;
        return {
            _id: userObj._id?.toString() || '',
            name: userObj.name,
            role: (userObj.roles && userObj.roles.length > 0) ? userObj.roles[0] : role_enum_1.Role.STUDENT,
            bio: userObj.bio,
            skills: userObj.skills || [],
            avatar: userObj.avatar,
            isVerified: userObj.isVerified || false,
            company: userObj.company,
            position: userObj.position,
            experienceYears: userObj.experienceYears || 0,
        };
    }
};
exports.UsersService = UsersService;
exports.UsersService = UsersService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, mongoose_1.InjectModel)(user_schema_1.User.name)),
    __metadata("design:paramtypes", [mongoose_2.Model])
], UsersService);
//# sourceMappingURL=users.service.js.map