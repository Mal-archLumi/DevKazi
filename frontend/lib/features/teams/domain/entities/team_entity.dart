// domain/entities/team_entity.dart
import 'package:equatable/equatable.dart';

class TeamEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final List<String>? skills; // Keep nullable but handle in UI
  final List<TeamMember> members;
  final int memberCount;
  final int? maxMembers;
  final String creatorId;
  final DateTime? lastActivity;
  final DateTime? createdAt;

  const TeamEntity({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.skills, // Nullable
    this.members = const [],
    this.memberCount = 0,
    this.maxMembers,
    required this.creatorId,
    this.lastActivity,
    this.createdAt,
  });

  // Helper getter to safely get skills
  List<String> get safeSkills => skills ?? [];

  // Add this getter - same as browse teams
  String get initial {
    if (name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    return '?';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    logoUrl,
    skills,
    members,
    memberCount,
    maxMembers,
    creatorId,
    lastActivity,
    createdAt,
  ];

  copyWith({required List<dynamic> members}) {}
}

class TeamMember extends Equatable {
  final String odooUserId;
  final String odooEmployeeId;
  final String userId;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? role;
  final DateTime? joinedAt;

  const TeamMember({
    this.odooUserId = '',
    this.odooEmployeeId = '',
    required this.userId,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.role,
    this.joinedAt,
  });

  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    // Handle nested user object
    final user = json['user'];

    String odooUserId = '';
    String odooEmployeeId = '';
    String odooId = '';
    String name = '';
    String email = '';
    String? avatarUrl;

    if (user is Map<String, dynamic>) {
      odooUserId = user['odooUserId']?.toString() ?? '';
      odooEmployeeId = user['odooEmployeeId']?.toString() ?? '';
      odooId = user['_id']?.toString() ?? user['id']?.toString() ?? '';
      name = user['name']?.toString() ?? '';
      email = user['email']?.toString() ?? '';
      avatarUrl = user['avatarUrl']?.toString();
    } else if (user is String) {
      odooId = user;
    }

    return TeamMember(
      odooUserId: odooUserId,
      odooEmployeeId: odooEmployeeId,
      userId: odooId,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      role: json['role']?.toString(),
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [
    odooUserId,
    odooEmployeeId,
    userId,
    name,
    email,
    avatarUrl,
    role,
    joinedAt,
  ];

  get avatar => null;

  get isOnline => null;

  copyWith({required bool isOnline}) {}
}
