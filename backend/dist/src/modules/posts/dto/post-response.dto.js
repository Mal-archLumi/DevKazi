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
exports.PostResponseDto = exports.UserResponseDto = exports.TeamResponseDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const mongoose_1 = require("mongoose");
class TeamResponseDto {
    _id;
    name;
    avatar;
    description;
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
__decorate([
    (0, swagger_1.ApiPropertyOptional)(),
    __metadata("design:type", String)
], TeamResponseDto.prototype, "description", void 0);
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
class PostResponseDto {
    _id;
    title;
    description;
    requirements;
    skillsRequired;
    category;
    team;
    createdBy;
    applicationDeadline;
    duration;
    commitment;
    location;
    stipend;
    positions;
    applicationsCount;
    status;
    tags;
    isPublic;
    createdAt;
    updatedAt;
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
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], PostResponseDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Array)
], PostResponseDto.prototype, "requirements", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Array)
], PostResponseDto.prototype, "skillsRequired", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], PostResponseDto.prototype, "category", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ type: TeamResponseDto }),
    __metadata("design:type", TeamResponseDto)
], PostResponseDto.prototype, "team", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ type: UserResponseDto }),
    __metadata("design:type", UserResponseDto)
], PostResponseDto.prototype, "createdBy", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Date)
], PostResponseDto.prototype, "applicationDeadline", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], PostResponseDto.prototype, "duration", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], PostResponseDto.prototype, "commitment", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], PostResponseDto.prototype, "location", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)(),
    __metadata("design:type", Number)
], PostResponseDto.prototype, "stipend", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], PostResponseDto.prototype, "positions", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], PostResponseDto.prototype, "applicationsCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], PostResponseDto.prototype, "status", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Array)
], PostResponseDto.prototype, "tags", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Boolean)
], PostResponseDto.prototype, "isPublic", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Date)
], PostResponseDto.prototype, "createdAt", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Date)
], PostResponseDto.prototype, "updatedAt", void 0);
//# sourceMappingURL=post-response.dto.js.map