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
exports.PostSchema = exports.Post = void 0;
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
const swagger_1 = require("@nestjs/swagger");
let Post = class Post {
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
};
exports.Post = Post;
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Post ID' }),
    __metadata("design:type", mongoose_2.Types.ObjectId)
], Post.prototype, "_id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Post title' }),
    (0, mongoose_1.Prop)({ required: true, trim: true, maxlength: 200 }),
    __metadata("design:type", String)
], Post.prototype, "title", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Post description' }),
    (0, mongoose_1.Prop)({ required: true, trim: true }),
    __metadata("design:type", String)
], Post.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Requirements for the internship' }),
    (0, mongoose_1.Prop)({ type: [String], default: [] }),
    __metadata("design:type", Array)
], Post.prototype, "requirements", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Skills required' }),
    (0, mongoose_1.Prop)({ type: [String], default: [] }),
    __metadata("design:type", Array)
], Post.prototype, "skillsRequired", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Category of internship' }),
    (0, mongoose_1.Prop)({ required: true, trim: true }),
    __metadata("design:type", String)
], Post.prototype, "category", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'Team that created the post (optional)' }),
    (0, mongoose_1.Prop)({ type: mongoose_2.Types.ObjectId, ref: 'Team', index: true }),
    __metadata("design:type", mongoose_2.Types.ObjectId)
], Post.prototype, "team", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'User who created the post' }),
    (0, mongoose_1.Prop)({ type: mongoose_2.Types.ObjectId, ref: 'User', required: true, index: true }),
    __metadata("design:type", mongoose_2.Types.ObjectId)
], Post.prototype, "createdBy", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Application deadline' }),
    (0, mongoose_1.Prop)({ required: true }),
    __metadata("design:type", Date)
], Post.prototype, "applicationDeadline", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Internship duration' }),
    (0, mongoose_1.Prop)({ required: true }),
    __metadata("design:type", String)
], Post.prototype, "duration", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Commitment level' }),
    (0, mongoose_1.Prop)({ required: true, enum: ['full-time', 'part-time', 'contract'] }),
    __metadata("design:type", String)
], Post.prototype, "commitment", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Location type' }),
    (0, mongoose_1.Prop)({ required: true, enum: ['remote', 'hybrid', 'onsite'] }),
    __metadata("design:type", String)
], Post.prototype, "location", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'Stipend amount' }),
    (0, mongoose_1.Prop)({ min: 0 }),
    __metadata("design:type", Number)
], Post.prototype, "stipend", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Number of positions available' }),
    (0, mongoose_1.Prop)({ required: true, min: 1, default: 1 }),
    __metadata("design:type", Number)
], Post.prototype, "positions", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Number of applications received' }),
    (0, mongoose_1.Prop)({ default: 0, min: 0 }),
    __metadata("design:type", Number)
], Post.prototype, "applicationsCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Post status' }),
    (0, mongoose_1.Prop)({
        enum: ['active', 'closed', 'draft'],
        default: 'active'
    }),
    __metadata("design:type", String)
], Post.prototype, "status", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Tags for searchability' }),
    (0, mongoose_1.Prop)({ type: [String], default: [], index: true }),
    __metadata("design:type", Array)
], Post.prototype, "tags", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Whether post is public' }),
    (0, mongoose_1.Prop)({ default: true }),
    __metadata("design:type", Boolean)
], Post.prototype, "isPublic", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Created at timestamp' }),
    __metadata("design:type", Date)
], Post.prototype, "createdAt", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Updated at timestamp' }),
    __metadata("design:type", Date)
], Post.prototype, "updatedAt", void 0);
exports.Post = Post = __decorate([
    (0, mongoose_1.Schema)({ timestamps: true, versionKey: false })
], Post);
exports.PostSchema = mongoose_1.SchemaFactory.createForClass(Post);
exports.PostSchema.index({ team: 1, status: 1 });
exports.PostSchema.index({ category: 1, status: 1 });
exports.PostSchema.index({ applicationDeadline: 1 });
exports.PostSchema.index({ tags: 1 });
//# sourceMappingURL=post.schema.js.map