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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TeamsService = void 0;
const common_1 = require("@nestjs/common");
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
const team_schema_1 = require("./schemas/team.schema");
let TeamsService = class TeamsService {
    teamModel;
    constructor(teamModel) {
        this.teamModel = teamModel;
    }
    async create(createTeamDto) {
        const team = new this.teamModel(createTeamDto);
        return team.save();
    }
    async findAll() {
        return this.teamModel.find().populate('owner', 'name email').populate('members.userId', 'name email');
    }
    async findById(id) {
        const team = await this.teamModel.findById(id)
            .populate('owner', 'name email')
            .populate('members.userId', 'name email skills');
        if (!team) {
            throw new common_1.NotFoundException('Team not found');
        }
        return team;
    }
    async update(id, updateTeamDto) {
        const team = await this.teamModel.findByIdAndUpdate(id, updateTeamDto, { new: true });
        if (!team) {
            throw new common_1.NotFoundException('Team not found');
        }
        return team;
    }
    async addMember(teamId, memberData) {
        return this.teamModel.findByIdAndUpdate(teamId, { $push: { members: memberData } }, { new: true });
    }
    async findBySkills(skills) {
        return this.teamModel.find({
            'requiredRoles.skills': { $in: skills },
            status: 'active'
        }).populate('owner', 'name email');
    }
};
exports.TeamsService = TeamsService;
exports.TeamsService = TeamsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, mongoose_1.InjectModel)(team_schema_1.Team.name)),
    __metadata("design:paramtypes", [mongoose_2.Model])
], TeamsService);
//# sourceMappingURL=teams.service.js.map