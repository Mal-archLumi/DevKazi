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
exports.UsersController = void 0;
const common_1 = require("@nestjs/common");
const users_service_1 = require("../users.service");
const update_profile_dto_1 = require("./update-profile.dto");
const search_users_dto_1 = require("./search-users.dto");
const skills_dto_1 = require("./skills.dto");
const user_response_dto_1 = require("./user-response.dto");
const jwt_auth_guard_1 = require("../../../auth/guards/jwt-auth.guard");
const roles_guard_1 = require("../../../auth/guards/roles.guard");
const role_enum_1 = require("../../../auth/enums/role.enum");
const current_user_decorator_1 = require("../../../auth/decorators/current-user.decorator");
const swagger_1 = require("@nestjs/swagger");
let UsersController = class UsersController {
    usersService;
    constructor(usersService) {
        this.usersService = usersService;
    }
    async getProfile(user) {
        return this.usersService.getProfile(user.userId);
    }
    async updateProfile(user, updateProfileDto) {
        return this.usersService.updateProfile(user.userId, updateProfileDto);
    }
    async deleteAccount(user) {
        await this.usersService.deleteAccount(user.userId);
        return { message: 'Account deleted successfully' };
    }
    async getPublicProfile(id) {
        return this.usersService.getPublicProfile(id);
    }
    async addSkills(user, addSkillsDto) {
        return this.usersService.addSkills(user.userId, addSkillsDto.skills);
    }
    async removeSkills(user, removeSkillsDto) {
        return this.usersService.removeSkills(user.userId, removeSkillsDto.skills);
    }
    async searchUsers(searchDto) {
        return this.usersService.searchUsers(searchDto);
    }
    async getMentors() {
        return this.usersService.getMentors();
    }
    async getStudents() {
        return this.usersService.getStudents();
    }
    async requestVerification(user) {
        return this.usersService.requestVerification(user.userId);
    }
};
exports.UsersController = UsersController;
__decorate([
    (0, common_1.Get)('profile'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: 'Get current user profile' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'User profile retrieved successfully', type: user_response_dto_1.UserResponseDto }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "getProfile", null);
__decorate([
    (0, common_1.Put)('profile'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: 'Update user profile' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Profile updated successfully', type: user_response_dto_1.UserResponseDto }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, update_profile_dto_1.UpdateProfileDto]),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "updateProfile", null);
__decorate([
    (0, common_1.Delete)('profile'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: 'Delete user account' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Account deleted successfully' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "deleteAccount", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Get public user profile' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Public profile retrieved successfully', type: user_response_dto_1.PublicUserResponseDto }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "getPublicProfile", null);
__decorate([
    (0, common_1.Post)('skills'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: 'Add skills to user profile' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Skills added successfully', type: user_response_dto_1.UserResponseDto }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, skills_dto_1.AddSkillsDto]),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "addSkills", null);
__decorate([
    (0, common_1.Delete)('skills'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: 'Remove skills from user profile' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Skills removed successfully', type: user_response_dto_1.UserResponseDto }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, skills_dto_1.RemoveSkillsDto]),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "removeSkills", null);
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: 'Search and list users' }),
    (0, swagger_1.ApiQuery)({ name: 'query', required: false, type: String }),
    (0, swagger_1.ApiQuery)({ name: 'role', required: false, enum: role_enum_1.Role }),
    (0, swagger_1.ApiQuery)({ name: 'skills', required: false, type: String, isArray: true }),
    (0, swagger_1.ApiQuery)({ name: 'page', required: false, type: Number }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, type: Number }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Users retrieved successfully' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [search_users_dto_1.SearchUsersDto]),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "searchUsers", null);
__decorate([
    (0, common_1.Get)('mentors/all'),
    (0, swagger_1.ApiOperation)({ summary: 'Get all public mentors' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Mentors retrieved successfully', type: [user_response_dto_1.PublicUserResponseDto] }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "getMentors", null);
__decorate([
    (0, common_1.Get)('students/all'),
    (0, swagger_1.ApiOperation)({ summary: 'Get all public students' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Students retrieved successfully', type: [user_response_dto_1.PublicUserResponseDto] }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "getStudents", null);
__decorate([
    (0, common_1.Post)('verify'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: 'Request profile verification' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Verification request submitted' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "requestVerification", null);
exports.UsersController = UsersController = __decorate([
    (0, swagger_1.ApiTags)('users'),
    (0, common_1.Controller)('users'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    __metadata("design:paramtypes", [users_service_1.UsersService])
], UsersController);
//# sourceMappingURL=users.controller.js.map