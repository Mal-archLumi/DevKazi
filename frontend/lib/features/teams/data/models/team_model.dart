// data/models/team_model.dart
import '../../domain/entities/team_entity.dart';

class TeamModel extends TeamEntity {
  const TeamModel({
    // REMOVE: const
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
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      logoUrl: json['logoUrl'],
      memberCount: _parseMemberCount(json), // CHANGED: Handle different formats
      createdAt: _parseDateTime(json['createdAt']),
      lastActivity: _parseDateTime(json['lastActivity'] ?? json['createdAt']),
      ownerName: json['owner'] != null
          ? (json['owner'] is String ? json['owner'] : json['owner']['name'])
          : null,
      isMember: json['isMember'] ?? false,
      inviteCode: json['inviteCode'],
    );
  }

  static int _parseMemberCount(Map<String, dynamic> json) {
    // Try members array length first
    if (json['members'] is List) {
      return (json['members'] as List).length;
    }
    // Fallback to memberCount field
    return json['memberCount'] ?? 1;
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
      'inviteCode': inviteCode, // ADD
    };
  }
}
