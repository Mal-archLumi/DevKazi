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
exports.ApplicationsService = void 0;
const common_1 = require("@nestjs/common");
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
const application_schema_1 = require("./schemas/application.schema");
let ApplicationsService = class ApplicationsService {
    applicationModel;
    constructor(applicationModel) {
        this.applicationModel = applicationModel;
    }
    async create(createApplicationDto) {
        const application = new this.applicationModel(createApplicationDto);
        return application.save();
    }
    async findByUser(userId) {
        return this.applicationModel.find({ applicant: userId })
            .populate('post', 'title type')
            .populate('team', 'name')
            .sort({ createdAt: -1 });
    }
    async findByPost(postId) {
        return this.applicationModel.find({ post: postId })
            .populate('applicant', 'name email skills')
            .sort({ createdAt: -1 });
    }
    async updateStatus(applicationId, status) {
        const application = await this.applicationModel.findByIdAndUpdate(applicationId, { status }, { new: true });
        if (!application) {
            throw new common_1.NotFoundException('Application not found');
        }
        return application;
    }
};
exports.ApplicationsService = ApplicationsService;
exports.ApplicationsService = ApplicationsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, mongoose_1.InjectModel)(application_schema_1.Application.name)),
    __metadata("design:paramtypes", [mongoose_2.Model])
], ApplicationsService);
//# sourceMappingURL=applications.service.js.map