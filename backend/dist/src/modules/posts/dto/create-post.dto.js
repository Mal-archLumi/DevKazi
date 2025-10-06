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
exports.CreatePostDto = void 0;
const class_validator_1 = require("class-validator");
const class_transformer_1 = require("class-transformer");
const swagger_1 = require("@nestjs/swagger");
class CreatePostDto {
    title;
    description;
    requirements;
    skillsRequired;
    category;
    team;
    applicationDeadline;
    duration;
    commitment;
    location;
    stipend;
    positions;
    tags;
    isPublic;
}
exports.CreatePostDto = CreatePostDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Post title', maxLength: 200 }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(200),
    __metadata("design:type", String)
], CreatePostDto.prototype, "title", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Post description' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreatePostDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Requirements for the internship' }),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsString)({ each: true }),
    (0, class_validator_1.ArrayMinSize)(1),
    __metadata("design:type", Array)
], CreatePostDto.prototype, "requirements", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Skills required' }),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsString)({ each: true }),
    (0, class_validator_1.ArrayMinSize)(1),
    __metadata("design:type", Array)
], CreatePostDto.prototype, "skillsRequired", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Category of internship' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreatePostDto.prototype, "category", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'Team ID (optional - for existing teams)' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsMongoId)(),
    __metadata("design:type", String)
], CreatePostDto.prototype, "team", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Application deadline' }),
    (0, class_validator_1.IsDate)(),
    (0, class_transformer_1.Type)(() => Date),
    __metadata("design:type", Date)
], CreatePostDto.prototype, "applicationDeadline", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Internship duration' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreatePostDto.prototype, "duration", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Commitment level', enum: ['full-time', 'part-time', 'contract'] }),
    (0, class_validator_1.IsEnum)(['full-time', 'part-time', 'contract']),
    __metadata("design:type", String)
], CreatePostDto.prototype, "commitment", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Location type', enum: ['remote', 'hybrid', 'onsite'] }),
    (0, class_validator_1.IsEnum)(['remote', 'hybrid', 'onsite']),
    __metadata("design:type", String)
], CreatePostDto.prototype, "location", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'Stipend amount' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0),
    __metadata("design:type", Number)
], CreatePostDto.prototype, "stipend", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Number of positions available', minimum: 1 }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    __metadata("design:type", Number)
], CreatePostDto.prototype, "positions", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'Tags for searchability' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsString)({ each: true }),
    __metadata("design:type", Array)
], CreatePostDto.prototype, "tags", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'Whether post is public' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsBoolean)(),
    __metadata("design:type", Boolean)
], CreatePostDto.prototype, "isPublic", void 0);
//# sourceMappingURL=create-post.dto.js.map