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
exports.UserSchema = exports.User = void 0;
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
const role_enum_1 = require("../../../auth/enums/role.enum");
let User = class User extends mongoose_2.Document {
    email;
    password;
    name;
    skills;
    bio;
    education;
    avatar;
    roles;
    isVerified;
    isProfilePublic;
    company;
    position;
    github;
    linkedin;
    portfolio;
    experienceYears;
    isActive;
    createdAt;
    updatedAt;
};
exports.User = User;
__decorate([
    (0, mongoose_1.Prop)({ required: true, unique: true, lowercase: true, index: true }),
    __metadata("design:type", String)
], User.prototype, "email", void 0);
__decorate([
    (0, mongoose_1.Prop)({ required: true, minlength: 8 }),
    __metadata("design:type", String)
], User.prototype, "password", void 0);
__decorate([
    (0, mongoose_1.Prop)({ required: true, trim: true, minlength: 2, maxlength: 50 }),
    __metadata("design:type", String)
], User.prototype, "name", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: [String], default: [] }),
    __metadata("design:type", Array)
], User.prototype, "skills", void 0);
__decorate([
    (0, mongoose_1.Prop)({ trim: true, maxlength: 500 }),
    __metadata("design:type", String)
], User.prototype, "bio", void 0);
__decorate([
    (0, mongoose_1.Prop)({ trim: true, maxlength: 200 }),
    __metadata("design:type", String)
], User.prototype, "education", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", String)
], User.prototype, "avatar", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: [String], enum: Object.values(role_enum_1.Role), default: [role_enum_1.Role.STUDENT] }),
    __metadata("design:type", Array)
], User.prototype, "roles", void 0);
__decorate([
    (0, mongoose_1.Prop)({ default: false }),
    __metadata("design:type", Boolean)
], User.prototype, "isVerified", void 0);
__decorate([
    (0, mongoose_1.Prop)({ default: true }),
    __metadata("design:type", Boolean)
], User.prototype, "isProfilePublic", void 0);
__decorate([
    (0, mongoose_1.Prop)({ trim: true, maxlength: 100 }),
    __metadata("design:type", String)
], User.prototype, "company", void 0);
__decorate([
    (0, mongoose_1.Prop)({ trim: true, maxlength: 100 }),
    __metadata("design:type", String)
], User.prototype, "position", void 0);
__decorate([
    (0, mongoose_1.Prop)({ match: /^https?:\/\/.+\..+$/ }),
    __metadata("design:type", String)
], User.prototype, "github", void 0);
__decorate([
    (0, mongoose_1.Prop)({ match: /^https?:\/\/.+\..+$/ }),
    __metadata("design:type", String)
], User.prototype, "linkedin", void 0);
__decorate([
    (0, mongoose_1.Prop)({ match: /^https?:\/\/.+\..+$/ }),
    __metadata("design:type", String)
], User.prototype, "portfolio", void 0);
__decorate([
    (0, mongoose_1.Prop)({ min: 0, max: 50, default: 0 }),
    __metadata("design:type", Number)
], User.prototype, "experienceYears", void 0);
__decorate([
    (0, mongoose_1.Prop)({ default: true }),
    __metadata("design:type", Boolean)
], User.prototype, "isActive", void 0);
exports.User = User = __decorate([
    (0, mongoose_1.Schema)({ timestamps: true })
], User);
exports.UserSchema = mongoose_1.SchemaFactory.createForClass(User);
exports.UserSchema.index({ email: 1 });
exports.UserSchema.index({ skills: 1 });
exports.UserSchema.index({ name: 'text', bio: 'text', education: 'text' });
exports.UserSchema.index({ roles: 1 });
exports.UserSchema.index({ isActive: 1 });
exports.UserSchema.index({ isVerified: 1 });
exports.UserSchema.index({ isProfilePublic: 1 });
//# sourceMappingURL=user.schema.js.map