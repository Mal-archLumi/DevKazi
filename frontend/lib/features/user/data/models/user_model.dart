import 'package:frontend/features/auth/domain/entities/user_entity.dart';

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
    super.avatar,
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
      avatar: json['avatar'],
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
      avatar: avatar,
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
      avatar: avatar,
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
