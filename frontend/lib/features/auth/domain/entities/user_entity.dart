class UserEntity {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String accessToken;
  final String refreshToken;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.accessToken,
    required this.refreshToken,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? accessToken,
    String? refreshToken,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
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
}
