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
exports.ApplicationResponseDto = exports.TeamResponseDto = exports.UserResponseDto = exports.PostResponseDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const mongoose_1 = require("mongoose");
class PostResponseDto {
    _id;
    title;
    team;
}
exports.PostResponseDto = PostResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ type: String }),
    __metadata("design:type", mongoose_1.Types.ObjectId)
], PostResponseDto.prototype, "_id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], PostResponseDto.prototype, "title", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ type: () => Object }),
    __metadata("design:type", Object)
], PostResponseDto.prototype, "team", void 0);
class UserResponseDto {
    _id;
    name;
    avatar;
    email;
}
exports.UserResponseDto = UserResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ type: String }),
    __metadata("design:type", mongoose_1.Types.ObjectId)
], UserResponseDto.prototype, "_id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], UserResponseDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)(),
    __metadata("design:type", String)
], UserResponseDto.prototype, "avatar", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)(),
    __metadata("design:type", String)
], UserResponseDto.prototype, "email", void 0);
class TeamResponseDto {
    _id;
    name;
    avatar;
}
exports.TeamResponseDto = TeamResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ type: String }),
    __metadata("design:type", mongoose_1.Types.ObjectId)
], TeamResponseDto.prototype, "_id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], TeamResponseDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)(),
    __metadata("design:type", String)
], TeamResponseDto.prototype, "avatar", void 0);
class ApplicationResponseDto {
    _id;
    post;
    applicant;
    team;
    coverLetter;
    resume;
    skills;
    experience;
    status;
    appliedAt;
    reviewedAt;
    reviewedBy;
    notes;
    createdAt;
    updatedAt;
}
exports.ApplicationResponseDto = ApplicationResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ type: String }),
    __metadata("design:type", mongoose_1.Types.ObjectId)
], ApplicationResponseDto.prototype, "_id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ type: PostResponseDto }),
    __metadata("design:type", PostResponseDto)
], ApplicationResponseDto.prototype, "post", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ type: UserResponseDto }),
    __metadata("design:type", UserResponseDto)
], ApplicationResponseDto.prototype, "applicant", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ type: TeamResponseDto }),
    __metadata("design:type", TeamResponseDto)
], ApplicationResponseDto.prototype, "team", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], ApplicationResponseDto.prototype, "coverLetter", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)(),
    __metadata("design:type", String)
], ApplicationResponseDto.prototype, "resume", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Array)
], ApplicationResponseDto.prototype, "skills", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], ApplicationResponseDto.prototype, "experience", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], ApplicationResponseDto.prototype, "status", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Date)
], ApplicationResponseDto.prototype, "appliedAt", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)(),
    __metadata("design:type", Date)
], ApplicationResponseDto.prototype, "reviewedAt", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ type: UserResponseDto }),
    __metadata("design:type", UserResponseDto)
], ApplicationResponseDto.prototype, "reviewedBy", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)(),
    __metadata("design:type", String)
], ApplicationResponseDto.prototype, "notes", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Date)
], ApplicationResponseDto.prototype, "createdAt", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Date)
], ApplicationResponseDto.prototype, "updatedAt", void 0);
//# sourceMappingURL=application-response.dto.js.map