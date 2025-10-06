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
Object.defineProperty(exports, "__esModule", { value: true });
exports.RegisterDto = void 0;
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
class RegisterDto {
    email;
    name;
    password;
    roles;
    skills;
    bio;
    education;
    github;
    linkedin;
    company;
    position;
    experienceYears;
    isProfilePublic;
    isActive;
}
exports.RegisterDto = RegisterDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'user@example.com', description: 'User email address' }),
    (0, class_validator_1.IsEmail)({}, { message: 'Invalid email format' }),
    __metadata("design:type", String)
], RegisterDto.prototype, "email", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'John Doe', description: 'User full name' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MinLength)(2, { message: 'Name must be at least 2 characters long' }),
    (0, class_validator_1.MaxLength)(50, { message: 'Name cannot exceed 50 characters' }),
    __metadata("design:type", String)
], RegisterDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Password123!', description: 'User password (minimum 8 characters)' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MinLength)(8, { message: 'Password must be at least 8 characters long' }),
    __metadata("design:type", String)
], RegisterDto.prototype, "password", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: ['student'], description: 'User roles', required: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsString)({ each: true, message: 'Each role must be a string' }),
    __metadata("design:type", Array)
], RegisterDto.prototype, "roles", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: ['JavaScript', 'React'], description: 'User skills', required: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsString)({ each: true, message: 'Each skill must be a string' }),
    __metadata("design:type", Array)
], RegisterDto.prototype, "skills", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Full-stack developer with 3 years of experience', description: 'User bio', required: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(500, { message: 'Bio cannot exceed 500 characters' }),
    __metadata("design:type", String)
], RegisterDto.prototype, "bio", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Computer Science Degree', description: 'User education', required: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(100, { message: 'Education cannot exceed 100 characters' }),
    __metadata("design:type", String)
], RegisterDto.prototype, "education", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'https://github.com/user', description: 'GitHub profile URL', required: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUrl)({}, { message: 'Invalid GitHub URL' }),
    __metadata("design:type", String)
], RegisterDto.prototype, "github", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'https://linkedin.com/in/user', description: 'LinkedIn profile URL', required: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUrl)({}, { message: 'Invalid LinkedIn URL' }),
    __metadata("design:type", String)
], RegisterDto.prototype, "linkedin", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Tech Corp', description: 'User company', required: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(100, { message: 'Company name cannot exceed 100 characters' }),
    __metadata("design:type", String)
], RegisterDto.prototype, "company", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Senior Developer', description: 'User position', required: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(100, { message: 'Position cannot exceed 100 characters' }),
    __metadata("design:type", String)
], RegisterDto.prototype, "position", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 3, description: 'Years of experience', required: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.Min)(0, { message: 'Experience years cannot be negative' }),
    __metadata("design:type", Number)
], RegisterDto.prototype, "experienceYears", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: true, description: 'Whether profile is public', required: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsBoolean)(),
    __metadata("design:type", Boolean)
], RegisterDto.prototype, "isProfilePublic", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: true, description: 'Whether user is active', required: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsBoolean)(),
    __metadata("design:type", Boolean)
], RegisterDto.prototype, "isActive", void 0);
//# sourceMappingURL=register.dto.js.map