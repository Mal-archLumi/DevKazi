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
exports.TeamSchema = exports.Team = void 0;
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
let Team = class Team {
    name;
    description;
    skills;
    members;
    inviteCode;
    owner;
    lastActivity;
};
exports.Team = Team;
__decorate([
    (0, mongoose_1.Prop)({ required: true, trim: true, maxlength: 50 }),
    __metadata("design:type", String)
], Team.prototype, "name", void 0);
__decorate([
    (0, mongoose_1.Prop)({ trim: true, maxlength: 500 }),
    __metadata("design:type", String)
], Team.prototype, "description", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: [{ type: String }], default: [] }),
    __metadata("design:type", Array)
], Team.prototype, "skills", void 0);
__decorate([
    (0, mongoose_1.Prop)({
        type: [
            {
                user: { type: mongoose_2.Types.ObjectId, ref: 'User', required: true },
                joinedAt: { type: Date, default: Date.now },
            },
        ],
        default: []
    }),
    __metadata("design:type", Array)
], Team.prototype, "members", void 0);
__decorate([
    (0, mongoose_1.Prop)({ required: true, unique: true }),
    __metadata("design:type", String)
], Team.prototype, "inviteCode", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: mongoose_2.Types.ObjectId, ref: 'User', required: true }),
    __metadata("design:type", Object)
], Team.prototype, "owner", void 0);
__decorate([
    (0, mongoose_1.Prop)({ default: Date.now }),
    __metadata("design:type", Date)
], Team.prototype, "lastActivity", void 0);
exports.Team = Team = __decorate([
    (0, mongoose_1.Schema)({ timestamps: true })
], Team);
exports.TeamSchema = mongoose_1.SchemaFactory.createForClass(Team);
exports.TeamSchema.index({ inviteCode: 1 }, { unique: true });
exports.TeamSchema.index({ 'members.user': 1 });
exports.TeamSchema.index({ lastActivity: -1 });
exports.TeamSchema.index({ owner: 1 });
//# sourceMappingURL=team.schema.js.map