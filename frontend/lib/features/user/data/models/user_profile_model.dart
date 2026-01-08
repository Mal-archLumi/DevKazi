// features/user/data/models/user_profile_model.dart

import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final List<String> skills;
  final String? bio;
  final String? education;
  final String? avatar;
  final bool isVerified;
  final bool isProfilePublic;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int projectCount;
  final int teamCount;

  const UserProfileEntity({
    required this.id,
    required this.email,
    required this.name,
    this.skills = const [],
    this.bio,
    this.education,
    this.avatar,
    this.isVerified = false,
    this.isProfilePublic = true,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required this.projectCount,
    required this.teamCount,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'U';

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    skills,
    bio,
    education,
    avatar,
    isVerified,
    isProfilePublic,
    isActive,
    createdAt,
    updatedAt,
    projectCount,
    teamCount,
  ];

  UserProfileEntity copyWith({
    String? id,
    String? email,
    String? name,
    List<String>? skills,
    String? bio,
    String? education,
    String? avatar,
    bool? isVerified,
    bool? isProfilePublic,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? projectCount,
    int? teamCount,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      education: education ?? this.education,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified ?? this.isVerified,
      isProfilePublic: isProfilePublic ?? this.isProfilePublic,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      projectCount: projectCount ?? this.projectCount,
      teamCount: teamCount ?? this.teamCount,
    );
  }
}

// Model class for API responses
class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.email,
    required super.name,
    super.skills = const [],
    super.bio,
    super.education,
    super.avatar,
    super.isVerified = false,
    super.isProfilePublic = true,
    super.isActive = true,
    required super.createdAt,
    required super.updatedAt,
    required super.projectCount,
    required super.teamCount,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
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
      'avatar': avatar,
      'projectCount': projectCount,
      'teamCount': teamCount,
    };
  }

  UserProfileEntity toEntity() {
    return UserProfileEntity(
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
      projectCount: projectCount,
      teamCount: teamCount,
    );
  }
}
