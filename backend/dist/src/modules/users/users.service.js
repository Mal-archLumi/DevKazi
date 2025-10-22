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
            isActive: true,
            isProfilePublic: true,
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
    validateSkills(skills) {
        const validatedSkills = skills
            .map(skill => skill.trim())
            .filter(skill => skill.length > 0);
        if (validatedSkills.length === 0) {
            throw new common_1.BadRequestException('No valid skills provided');
        }
        return validatedSkills;
    }
    mapToUserResponseDto(user) {
        const userObj = user.toObject ? user.toObject() : user;
        return {
            _id: userObj._id?.toString() || '',
            email: userObj.email,
            name: userObj.name,
            skills: userObj.skills || [],
            bio: userObj.bio,
            education: userObj.education,
            avatar: userObj.avatar,
            isVerified: userObj.isVerified || false,
            isProfilePublic: userObj.isProfilePublic !== undefined ? userObj.isProfilePublic : true,
            isActive: userObj.isActive !== undefined ? userObj.isActive : true,
            createdAt: userObj.createdAt || new Date(),
            updatedAt: userObj.updatedAt || new Date(),
        };
    }
    mapToPublicUserResponseDto(user) {
        const userObj = user.toObject ? user.toObject() : user;
        return {
            _id: userObj._id?.toString() || '',
            name: userObj.name,
            skills: userObj.skills || [],
            bio: userObj.bio,
            avatar: userObj.avatar,
            isVerified: userObj.isVerified || false,
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