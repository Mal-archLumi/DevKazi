class UserEntity {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String accessToken;
  final String refreshToken;
  final List<String> skills;
  final String? bio;
  final String? education;
  final String? avatar;
  final bool isVerified;
  final bool isProfilePublic;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.accessToken,
    required this.refreshToken,
    this.skills = const [],
    this.bio,
    this.education,
    this.avatar,
    this.isVerified = false,
    this.isProfilePublic = true,
    this.isActive = true,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'U';

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? accessToken,
    String? refreshToken,
    List<String>? skills,
    String? bio,
    String? education,
    String? avatar,
    bool? isVerified,
    bool? isProfilePublic,
    bool? isActive,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      education: education ?? this.education,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified ?? this.isVerified,
      isProfilePublic: isProfilePublic ?? this.isProfilePublic,
      isActive: isActive ?? this.isActive,
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
}
