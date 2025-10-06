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
exports.ApplicationSchema = exports.Application = void 0;
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
const swagger_1 = require("@nestjs/swagger");
let Application = class Application {
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
};
exports.Application = Application;
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Application ID' }),
    __metadata("design:type", mongoose_2.Types.ObjectId)
], Application.prototype, "_id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Post being applied to' }),
    (0, mongoose_1.Prop)({ type: mongoose_2.Types.ObjectId, ref: 'Post', required: true, index: true }),
    __metadata("design:type", mongoose_2.Types.ObjectId)
], Application.prototype, "post", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Applicant user' }),
    (0, mongoose_1.Prop)({ type: mongoose_2.Types.ObjectId, ref: 'User', required: true, index: true }),
    __metadata("design:type", mongoose_2.Types.ObjectId)
], Application.prototype, "applicant", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Team receiving the application' }),
    (0, mongoose_1.Prop)({ type: mongoose_2.Types.ObjectId, ref: 'Team', required: true, index: true }),
    __metadata("design:type", mongoose_2.Types.ObjectId)
], Application.prototype, "team", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Cover letter' }),
    (0, mongoose_1.Prop)({ required: true, trim: true }),
    __metadata("design:type", String)
], Application.prototype, "coverLetter", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Resume URL', required: false }),
    (0, mongoose_1.Prop)(),
    __metadata("design:type", String)
], Application.prototype, "resume", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Applicant skills' }),
    (0, mongoose_1.Prop)({ type: [String], default: [] }),
    __metadata("design:type", Array)
], Application.prototype, "skills", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Applicant experience' }),
    (0, mongoose_1.Prop)({ trim: true }),
    __metadata("design:type", String)
], Application.prototype, "experience", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Application status' }),
    (0, mongoose_1.Prop)({
        enum: ['pending', 'accepted', 'rejected', 'withdrawn'],
        default: 'pending'
    }),
    __metadata("design:type", String)
], Application.prototype, "status", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'When application was submitted' }),
    (0, mongoose_1.Prop)({ default: Date.now }),
    __metadata("design:type", Date)
], Application.prototype, "appliedAt", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'When application was reviewed', required: false }),
    (0, mongoose_1.Prop)(),
    __metadata("design:type", Date)
], Application.prototype, "reviewedAt", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Who reviewed the application', required: false }),
    (0, mongoose_1.Prop)({ type: mongoose_2.Types.ObjectId, ref: 'User' }),
    __metadata("design:type", mongoose_2.Types.ObjectId)
], Application.prototype, "reviewedBy", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Internal notes', required: false }),
    (0, mongoose_1.Prop)({ trim: true }),
    __metadata("design:type", String)
], Application.prototype, "notes", void 0);
exports.Application = Application = __decorate([
    (0, mongoose_1.Schema)({ timestamps: true, versionKey: false })
], Application);
exports.ApplicationSchema = mongoose_1.SchemaFactory.createForClass(Application);
exports.ApplicationSchema.index({ post: 1, applicant: 1 }, { unique: true });
exports.ApplicationSchema.index({ team: 1, status: 1 });
exports.ApplicationSchema.index({ applicant: 1, status: 1 });
//# sourceMappingURL=application.schema.js.map