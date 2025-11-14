// data/models/team_model.dart
import '../../domain/entities/team_entity.dart';

class TeamModel extends TeamEntity {
  const TeamModel({
    required super.id,
    required super.name,
    super.description,
    super.logoUrl,
    required super.memberCount,
    required super.createdAt,
    required super.lastActivity,
    super.ownerName,
    super.isMember,
    super.inviteCode,
    required super.members, // ADD THIS
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    print('🟡 TeamModel.fromJson: Starting parsing');
    print('🟡 TeamModel.fromJson: json keys: ${json.keys}');
    print('🟡 TeamModel.fromJson: members data: ${json['members']}');

    // Use TeamEntity.fromJson to parse members data
    final teamEntity = TeamEntity.fromJson(json);

    return TeamModel(
      id: teamEntity.id,
      name: teamEntity.name,
      description: teamEntity.description,
      logoUrl: teamEntity.logoUrl,
      memberCount: teamEntity.memberCount,
      createdAt: teamEntity.createdAt,
      lastActivity: teamEntity.lastActivity,
      ownerName: teamEntity.ownerName,
      isMember: teamEntity.isMember,
      inviteCode: teamEntity.inviteCode,
      members: teamEntity.members, // ADD THIS
    );
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        return DateTime.now();
      }
    }
    if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'memberCount': memberCount,
      'createdAt': createdAt.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'ownerName': ownerName,
      'isMember': isMember,
      'inviteCode': inviteCode,
    };
  }
}
