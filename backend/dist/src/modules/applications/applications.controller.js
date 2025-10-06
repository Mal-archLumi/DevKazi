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
exports.ApplicationsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const jwt_auth_guard_1 = require("../../auth/guards/jwt-auth.guard");
const applications_service_1 = require("./applications.service");
const create_application_dto_1 = require("./dto/create-application.dto");
const application_status_dto_1 = require("./dto/application-status.dto");
const application_response_dto_1 = require("./dto/application-response.dto");
let ApplicationsController = class ApplicationsController {
    applicationsService;
    constructor(applicationsService) {
        this.applicationsService = applicationsService;
    }
    async create(createApplicationDto, req) {
        return this.applicationsService.create(createApplicationDto, req.user.userId);
    }
    async getMyApplications(req) {
        return this.applicationsService.getUserApplications(req.user.userId);
    }
    async getTeamApplications(teamId, req) {
        return this.applicationsService.getTeamApplications(teamId, req.user.userId);
    }
    async updateStatus(id, statusDto, req) {
        return this.applicationsService.updateStatus(id, statusDto, req.user.userId);
    }
    async withdrawApplication(id, req) {
        return this.applicationsService.withdrawApplication(id, req.user.userId);
    }
    async getApplicationStats(teamId, req) {
        return this.applicationsService.getApplicationStats(teamId, req.user.userId);
    }
    async getApplicationAnalytics(teamId, req) {
        return this.applicationsService.getApplicationAnalytics(teamId, req.user.userId);
    }
};
exports.ApplicationsController = ApplicationsController;
__decorate([
    (0, common_1.Post)(),
    (0, swagger_1.ApiOperation)({ summary: 'Apply for an internship post' }),
    (0, swagger_1.ApiResponse)({ status: 201, description: 'Application submitted successfully', type: application_response_dto_1.ApplicationResponseDto }),
    (0, swagger_1.ApiResponse)({ status: 400, description: 'Invalid application data' }),
    (0, swagger_1.ApiResponse)({ status: 403, description: 'Forbidden' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_application_dto_1.CreateApplicationDto, Object]),
    __metadata("design:returntype", Promise)
], ApplicationsController.prototype, "create", null);
__decorate([
    (0, common_1.Get)('my-applications'),
    (0, swagger_1.ApiOperation)({ summary: 'Get all applications by the current user' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Applications retrieved successfully' }),
    __param(0, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], ApplicationsController.prototype, "getMyApplications", null);
__decorate([
    (0, common_1.Get)('team/:teamId'),
    (0, swagger_1.ApiOperation)({ summary: 'Get all applications for a team' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Team applications retrieved successfully' }),
    (0, swagger_1.ApiResponse)({ status: 403, description: 'Forbidden - Not team admin' }),
    __param(0, (0, common_1.Param)('teamId')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], ApplicationsController.prototype, "getTeamApplications", null);
__decorate([
    (0, common_1.Put)(':id/status'),
    (0, swagger_1.ApiOperation)({ summary: 'Update application status' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Application status updated successfully', type: application_response_dto_1.ApplicationResponseDto }),
    (0, swagger_1.ApiResponse)({ status: 403, description: 'Forbidden - Not team admin' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, application_status_dto_1.ApplicationStatusDto, Object]),
    __metadata("design:returntype", Promise)
], ApplicationsController.prototype, "updateStatus", null);
__decorate([
    (0, common_1.Put)(':id/withdraw'),
    (0, swagger_1.ApiOperation)({ summary: 'Withdraw an application' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Application withdrawn successfully', type: application_response_dto_1.ApplicationResponseDto }),
    (0, swagger_1.ApiResponse)({ status: 403, description: 'Forbidden - Not application owner' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], ApplicationsController.prototype, "withdrawApplication", null);
__decorate([
    (0, common_1.Get)('team/:teamId/stats'),
    (0, swagger_1.ApiOperation)({ summary: 'Get application statistics for a team' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Statistics retrieved successfully' }),
    (0, swagger_1.ApiResponse)({ status: 403, description: 'Forbidden - Not team admin' }),
    __param(0, (0, common_1.Param)('teamId')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], ApplicationsController.prototype, "getApplicationStats", null);
__decorate([
    (0, common_1.Get)('team/:teamId/analytics'),
    (0, swagger_1.ApiOperation)({ summary: 'Get detailed application analytics for a team' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Analytics retrieved successfully' }),
    (0, swagger_1.ApiResponse)({ status: 403, description: 'Forbidden - Not team admin' }),
    __param(0, (0, common_1.Param)('teamId')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], ApplicationsController.prototype, "getApplicationAnalytics", null);
exports.ApplicationsController = ApplicationsController = __decorate([
    (0, swagger_1.ApiTags)('applications'),
    (0, common_1.Controller)('applications'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    __metadata("design:paramtypes", [applications_service_1.ApplicationsService])
], ApplicationsController);
//# sourceMappingURL=applications.controller.js.map