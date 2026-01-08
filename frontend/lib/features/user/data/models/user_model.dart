// features/user/data/models/user_model.dart

import 'package:frontend/features/auth/domain/entities/user_entity.dart';

// Since UserEntity doesn't have projectCount and teamCount,
// create a separate UserProfileModel for profile-related data
class UserProfileModel {
  final String id;
  final String email;
  final String name;
  final List<String> skills;
  final String? bio;
  final String? education;
  final String? picture;
  final bool isVerified;
  final bool isProfilePublic;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int projectCount;
  final int teamCount;

  const UserProfileModel({
    required this.id,
    required this.email,
    required this.name,
    this.skills = const [],
    this.bio,
    this.education,
    this.picture,
    this.isVerified = false,
    this.isProfilePublic = true,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required this.projectCount,
    required this.teamCount,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      bio: json['bio'],
      education: json['education'],
      picture: json['picture'] ?? json['avatar'],
      isVerified: json['isVerified'] ?? false,
      isProfilePublic: json['isProfilePublic'] ?? true,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      projectCount: json['projectCount'] ?? 0,
      teamCount: json['teamCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bio': bio,
      'education': education,
      'skills': skills,
      'isProfilePublic': isProfilePublic,
      'picture': picture,
    };
  }

  // Convert to UserEntity for auth operations
  UserEntity toUserEntity({
    required String accessToken,
    required String refreshToken,
  }) {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      skills: skills,
      bio: bio,
      education: education,
      picture: picture,
      isVerified: isVerified,
      isProfilePublic: isProfilePublic,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}

// Keep the original UserModel for auth-related operations
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.createdAt,
    required super.updatedAt,
    required super.accessToken,
    required super.refreshToken,
    super.skills = const [],
    super.bio,
    super.education,
    super.picture,
    super.isVerified = false,
    super.isProfilePublic = true,
    super.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      bio: json['bio'],
      education: json['education'],
      picture: json['picture'] ?? json['avatar'],
      isVerified: json['isVerified'] ?? false,
      isProfilePublic: json['isProfilePublic'] ?? true,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      accessToken: '', // These will be set separately from auth
      refreshToken: '', // These will be set separately from auth
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bio': bio,
      'education': education,
      'skills': skills,
      'isProfilePublic': isProfilePublic,
      'picture': picture,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      skills: skills,
      bio: bio,
      education: education,
      picture: picture,
      isVerified: isVerified,
      isProfilePublic: isProfilePublic,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  // Method to merge with auth data (tokens)
  UserModel mergeWithAuthData({
    required String accessToken,
    required String refreshToken,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name,
      skills: skills,
      bio: bio,
      education: education,
      picture: picture,
      isVerified: isVerified,
      isProfilePublic: isProfilePublic,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
