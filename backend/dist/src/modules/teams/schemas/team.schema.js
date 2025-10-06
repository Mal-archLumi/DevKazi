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
exports.TeamSchema = exports.Team = exports.TeamStatus = exports.TeamRole = void 0;
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
var TeamRole;
(function (TeamRole) {
    TeamRole["OWNER"] = "owner";
    TeamRole["ADMIN"] = "admin";
    TeamRole["MEMBER"] = "member";
})(TeamRole || (exports.TeamRole = TeamRole = {}));
var TeamStatus;
(function (TeamStatus) {
    TeamStatus["ACTIVE"] = "active";
    TeamStatus["INACTIVE"] = "inactive";
    TeamStatus["ARCHIVED"] = "archived";
})(TeamStatus || (exports.TeamStatus = TeamStatus = {}));
let Team = class Team {
    name;
    description;
    projectIdea;
    requiredSkills;
    preferredSkills;
    maxMembers;
    members;
    settings;
    pendingInvites;
    joinRequests;
    tags;
    avatarUrl;
    status;
    currentProjectCount;
    githubRepo;
    projectDemoUrl;
    completedProjects;
    successRate;
};
exports.Team = Team;
__decorate([
    (0, mongoose_1.Prop)({ required: true }),
    __metadata("design:type", String)
], Team.prototype, "name", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", String)
], Team.prototype, "description", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", String)
], Team.prototype, "projectIdea", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: [{ type: String }] }),
    __metadata("design:type", Array)
], Team.prototype, "requiredSkills", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: [{ type: String }] }),
    __metadata("design:type", Array)
], Team.prototype, "preferredSkills", void 0);
__decorate([
    (0, mongoose_1.Prop)({ default: 5 }),
    __metadata("design:type", Number)
], Team.prototype, "maxMembers", void 0);
__decorate([
    (0, mongoose_1.Prop)({
        type: [
            {
                user: { type: mongoose_2.Types.ObjectId, ref: 'User' },
                role: { type: String, enum: TeamRole, default: TeamRole.MEMBER },
                joinedAt: { type: Date, default: Date.now },
            },
        ],
    }),
    __metadata("design:type", Array)
], Team.prototype, "members", void 0);
__decorate([
    (0, mongoose_1.Prop)({
        type: {
            isPublic: { type: Boolean, default: true },
            allowJoinRequests: { type: Boolean, default: true },
            requireApproval: { type: Boolean, default: true },
        },
    }),
    __metadata("design:type", Object)
], Team.prototype, "settings", void 0);
__decorate([
    (0, mongoose_1.Prop)({
        type: [{ type: mongoose_2.Types.ObjectId, ref: 'User' }],
    }),
    __metadata("design:type", Array)
], Team.prototype, "pendingInvites", void 0);
__decorate([
    (0, mongoose_1.Prop)({
        type: [
            {
                user: { type: mongoose_2.Types.ObjectId, ref: 'User' },
                message: String,
                createdAt: { type: Date, default: Date.now },
            },
        ],
    }),
    __metadata("design:type", Array)
], Team.prototype, "joinRequests", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: [{ type: String }] }),
    __metadata("design:type", Array)
], Team.prototype, "tags", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", String)
], Team.prototype, "avatarUrl", void 0);
__decorate([
    (0, mongoose_1.Prop)({ default: TeamStatus.ACTIVE }),
    __metadata("design:type", String)
], Team.prototype, "status", void 0);
__decorate([
    (0, mongoose_1.Prop)({ default: 0 }),
    __metadata("design:type", Number)
], Team.prototype, "currentProjectCount", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", String)
], Team.prototype, "githubRepo", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", String)
], Team.prototype, "projectDemoUrl", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", Number)
], Team.prototype, "completedProjects", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", Number)
], Team.prototype, "successRate", void 0);
exports.Team = Team = __decorate([
    (0, mongoose_1.Schema)({ timestamps: true })
], Team);
exports.TeamSchema = mongoose_1.SchemaFactory.createForClass(Team);
exports.TeamSchema.index({ name: 'text', description: 'text', projectIdea: 'text' });
exports.TeamSchema.index({ 'members.user': 1 });
exports.TeamSchema.index({ requiredSkills: 1 });
exports.TeamSchema.index({ status: 1 });
exports.TeamSchema.index({ createdAt: -1 });
//# sourceMappingURL=team.schema.js.map