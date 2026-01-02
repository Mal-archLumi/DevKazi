// data/models/team_model.dart
import 'package:frontend/features/teams/domain/entities/team_entity.dart';

class TeamModel extends TeamEntity {
  const TeamModel({
    required super.id,
    required super.name,
    super.description,
    super.logoUrl,
    super.skills,
    super.members = const [],
    super.memberCount = 0,
    super.maxMembers,
    required super.creatorId,
    super.lastActivity,
    super.createdAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    // Safely parse skills - handle null, non-list, and list cases
    List<String>? skillsList;
    final rawSkills = json['skills'];
    if (rawSkills != null && rawSkills is List) {
      skillsList = rawSkills
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList()
          .cast<String>();
    }

    // Safely parse members
    List<TeamMember> membersList = [];
    final rawMembers = json['members'];
    if (rawMembers != null && rawMembers is List) {
      membersList = rawMembers
          .whereType<Map<String, dynamic>>()
          .map((m) => TeamMember.fromJson(m))
          .toList();
    }

    // Get owner/creator ID
    String creatorId = '';
    final owner = json['owner'];
    if (owner is Map<String, dynamic>) {
      creatorId = owner['_id']?.toString() ?? owner['id']?.toString() ?? '';
    } else if (owner is String) {
      creatorId = owner;
    } else {
      creatorId = json['creatorId']?.toString() ?? '';
    }

    return TeamModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      logoUrl: json['logoUrl']?.toString(),
      skills: skillsList,
      members: membersList,
      memberCount: json['memberCount'] as int? ?? membersList.length,
      maxMembers: json['maxMembers'] as int?,
      creatorId: creatorId,
      lastActivity: json['lastActivity'] != null
          ? DateTime.tryParse(json['lastActivity'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'skills': skills,
      'members': members
          .map(
            (m) => {
              'userId': m.userId,
              'name': m.name,
              'email': m.email,
              'avatarUrl': m.avatarUrl,
              'role': m.role,
              'joinedAt': m.joinedAt?.toIso8601String(),
            },
          )
          .toList(),
      'memberCount': memberCount,
      'maxMembers': maxMembers,
      'creatorId': creatorId,
      'lastActivity': lastActivity?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
