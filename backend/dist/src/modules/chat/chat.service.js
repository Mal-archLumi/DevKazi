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
exports.ChatService = void 0;
const common_1 = require("@nestjs/common");
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
const message_schema_1 = require("./schemas/message.schema");
let ChatService = class ChatService {
    messageModel;
    constructor(messageModel) {
        this.messageModel = messageModel;
    }
    async createMessage(createMessageDto) {
        if (!createMessageDto.team || !createMessageDto.sender || !createMessageDto.content) {
            throw new common_1.BadRequestException('Team, sender, and content are required');
        }
        if (createMessageDto.content.trim().length === 0) {
            throw new common_1.BadRequestException('Message content cannot be empty');
        }
        if (createMessageDto.content.length > 1000) {
            throw new common_1.BadRequestException('Message too long (max 1000 characters)');
        }
        const message = new this.messageModel({
            team: new mongoose_2.Types.ObjectId(createMessageDto.team),
            sender: new mongoose_2.Types.ObjectId(createMessageDto.sender),
            content: createMessageDto.content.trim(),
            timestamp: new Date(),
        });
        return message.save();
    }
    async getTeamMessages(teamId, limit = 100) {
        if (!mongoose_2.Types.ObjectId.isValid(teamId)) {
            throw new common_1.BadRequestException('Invalid team ID');
        }
        return this.messageModel
            .find({ team: new mongoose_2.Types.ObjectId(teamId) })
            .populate('sender', 'name email')
            .sort({ timestamp: 1 })
            .limit(limit)
            .exec();
    }
    async getRecentTeamMessages(teamId, limit = 50) {
        if (!mongoose_2.Types.ObjectId.isValid(teamId)) {
            throw new common_1.BadRequestException('Invalid team ID');
        }
        return this.messageModel
            .find({ team: new mongoose_2.Types.ObjectId(teamId) })
            .populate('sender', 'name email')
            .sort({ timestamp: -1 })
            .limit(limit)
            .exec();
    }
};
exports.ChatService = ChatService;
exports.ChatService = ChatService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, mongoose_1.InjectModel)(message_schema_1.Message.name)),
    __metadata("design:paramtypes", [mongoose_2.Model])
], ChatService);
//# sourceMappingURL=chat.service.js.map