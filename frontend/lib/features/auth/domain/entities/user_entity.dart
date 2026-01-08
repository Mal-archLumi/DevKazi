// features/auth/domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
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
  final String accessToken;
  final String refreshToken;

  const UserEntity({
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
    required this.accessToken,
    required this.refreshToken,
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
    picture,
    isVerified,
    isProfilePublic,
    isActive,
    createdAt,
    updatedAt,
    accessToken,
    refreshToken,
  ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    List<String>? skills,
    String? bio,
    String? education,
    String? picture,
    bool? isVerified,
    bool? isProfilePublic,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? accessToken,
    String? refreshToken,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      education: education ?? this.education,
      picture: picture ?? this.picture,
      isVerified: isVerified ?? this.isVerified,
      isProfilePublic: isProfilePublic ?? this.isProfilePublic,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserEntity &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        name.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        accessToken.hashCode ^
        refreshToken.hashCode;
  }

  get teams => null;
}
