"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PrivateUserResponseDto = exports.PublicUserResponseDto = exports.UserResponseDto = void 0;
class UserResponseDto {
    _id;
    email;
    name;
    skills;
    bio;
    education;
    avatar;
    role;
    isVerified;
    isProfilePublic;
    company;
    position;
    github;
    linkedin;
    portfolio;
    experienceYears;
    createdAt;
    updatedAt;
}
exports.UserResponseDto = UserResponseDto;
class PublicUserResponseDto {
    _id;
    name;
    role;
    bio;
    skills;
    avatar;
    isVerified;
    company;
    position;
    experienceYears;
}
exports.PublicUserResponseDto = PublicUserResponseDto;
class PrivateUserResponseDto extends UserResponseDto {
}
exports.PrivateUserResponseDto = PrivateUserResponseDto;
//# sourceMappingURL=user-response.dto.js.map