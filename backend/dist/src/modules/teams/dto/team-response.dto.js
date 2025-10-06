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
class TeamResponseDto {
    _id;
    name;
    avatar;
    description;
}
exports.TeamResponseDto = TeamResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
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
//# sourceMappingURL=team-response.dto.js.map