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
exports.UserRolesMigration = void 0;
const common_1 = require("@nestjs/common");
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
const user_schema_1 = require("../schemas/user.schema");
const role_enum_1 = require("../../../auth/enums/role.enum");
let UserRolesMigration = class UserRolesMigration {
    userModel;
    constructor(userModel) {
        this.userModel = userModel;
    }
    async migrateRoles() {
        console.log('Starting user roles migration...');
        const users = await this.userModel.find().exec();
        for (const user of users) {
            if (user.roles && user.roles.length > 0)
                continue;
            const userObj = user.toObject();
            if (userObj.role) {
                user.roles = [userObj.role];
            }
            else {
                user.roles = [role_enum_1.Role.STUDENT];
            }
            await user.save();
            console.log(`Migrated user ${user.email} to roles: ${user.roles.join(', ')}`);
        }
        console.log('User roles migration completed!');
    }
};
exports.UserRolesMigration = UserRolesMigration;
exports.UserRolesMigration = UserRolesMigration = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, mongoose_1.InjectModel)(user_schema_1.User.name)),
    __metadata("design:paramtypes", [mongoose_2.Model])
], UserRolesMigration);
//# sourceMappingURL=user-roles.migration.js.map