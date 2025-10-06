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
exports.UpdatePostDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const create_post_dto_1 = require("./create-post.dto");
const class_validator_1 = require("class-validator");
const class_transformer_1 = require("class-transformer");
const swagger_2 = require("@nestjs/swagger");
class UpdatePostDto extends (0, swagger_1.PartialType)(create_post_dto_1.CreatePostDto) {
    status;
    applicationDeadline;
    positions;
    stipend;
}
exports.UpdatePostDto = UpdatePostDto;
__decorate([
    (0, swagger_2.ApiPropertyOptional)({
        description: 'Post status',
        enum: ['active', 'closed', 'draft']
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(['active', 'closed', 'draft']),
    __metadata("design:type", String)
], UpdatePostDto.prototype, "status", void 0);
__decorate([
    (0, swagger_2.ApiPropertyOptional)({ description: 'Application deadline' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsDate)(),
    (0, class_transformer_1.Type)(() => Date),
    __metadata("design:type", Date)
], UpdatePostDto.prototype, "applicationDeadline", void 0);
__decorate([
    (0, swagger_2.ApiPropertyOptional)({ description: 'Number of positions available', minimum: 1 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    __metadata("design:type", Number)
], UpdatePostDto.prototype, "positions", void 0);
__decorate([
    (0, swagger_2.ApiPropertyOptional)({ description: 'Stipend amount', minimum: 0 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0),
    __metadata("design:type", Number)
], UpdatePostDto.prototype, "stipend", void 0);
//# sourceMappingURL=update-post.dto.js.map