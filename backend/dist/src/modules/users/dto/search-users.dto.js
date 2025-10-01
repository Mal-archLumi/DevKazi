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
exports.SearchUsersDto = void 0;
const class_validator_1 = require("class-validator");
const role_enum_1 = require("../../../auth/enums/role.enum");
const class_transformer_1 = require("class-transformer");
const swagger_1 = require("@nestjs/swagger");
class SearchUsersDto {
    query;
    role;
    skills;
    verifiedOnly = false;
    page = 1;
    limit = 10;
}
exports.SearchUsersDto = SearchUsersDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        required: false,
        description: 'Search query for name, bio, education, or skills',
        example: 'JavaScript'
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], SearchUsersDto.prototype, "query", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        required: false,
        enum: role_enum_1.Role,
        description: 'Filter by user role',
        example: role_enum_1.Role.MENTOR
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(role_enum_1.Role),
    __metadata("design:type", String)
], SearchUsersDto.prototype, "role", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        required: false,
        description: 'Filter by skills (comma-separated)',
        example: 'JavaScript,React,Node.js',
        type: [String]
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsString)({ each: true }),
    (0, class_transformer_1.Transform)(({ value }) => {
        if (typeof value === 'string') {
            return value.split(',').map(skill => skill.trim()).filter(skill => skill.length > 0);
        }
        if (Array.isArray(value)) {
            return value.filter(skill => typeof skill === 'string' && skill.length > 0);
        }
        return [];
    }),
    __metadata("design:type", Array)
], SearchUsersDto.prototype, "skills", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        required: false,
        description: 'Show only verified users',
        example: false,
        default: false
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsBoolean)(),
    (0, class_transformer_1.Transform)(({ value }) => {
        if (value === 'true')
            return true;
        if (value === 'false')
            return false;
        return Boolean(value);
    }),
    __metadata("design:type", Boolean)
], SearchUsersDto.prototype, "verifiedOnly", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        required: false,
        description: 'Page number for pagination',
        example: 1,
        default: 1
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Transform)(({ value }) => {
        const num = parseInt(value, 10);
        return isNaN(num) || num < 1 ? 1 : num;
    }),
    (0, class_validator_1.Min)(1),
    __metadata("design:type", Number)
], SearchUsersDto.prototype, "page", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        required: false,
        description: 'Number of items per page',
        example: 10,
        default: 10,
        maximum: 100
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Transform)(({ value }) => {
        const num = parseInt(value, 10);
        if (isNaN(num) || num < 1)
            return 10;
        return Math.min(num, 100);
    }),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(100),
    __metadata("design:type", Number)
], SearchUsersDto.prototype, "limit", void 0);
//# sourceMappingURL=search-users.dto.js.map