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
exports.TeamResponseDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const mongoose_1 = require("mongoose");
class TeamMemberDto {
    user;
    name;
    email;
    joinedAt;
}
__decorate([
    (0, swagger_1.ApiProperty)({ type: String }),
    __metadata("design:type", mongoose_1.Types.ObjectId)
], TeamMemberDto.prototype, "user", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], TeamMemberDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], TeamMemberDto.prototype, "email", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Date)
], TeamMemberDto.prototype, "joinedAt", void 0);
class TeamResponseDto {
    _id;
    name;
    description;
    skills;
    members;
    inviteCode;
    createdAt;
    lastActivity;
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
], TeamResponseDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)(),
    __metadata("design:type", Array)
], TeamResponseDto.prototype, "skills", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ type: [TeamMemberDto] }),
    __metadata("design:type", Array)
], TeamResponseDto.prototype, "members", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], TeamResponseDto.prototype, "inviteCode", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Date)
], TeamResponseDto.prototype, "createdAt", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Date)
], TeamResponseDto.prototype, "lastActivity", void 0);
//# sourceMappingURL=team-response.dto.js.map