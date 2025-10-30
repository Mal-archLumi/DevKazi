// data/models/team_model.dart
import '../../domain/entities/team_entity.dart';

class TeamModel extends TeamEntity {
  const TeamModel({
    required String id,
    required String name,
    String? description,
    String? logoUrl,
    required int memberCount,
    required DateTime createdAt,
    required DateTime lastActivity,
    String? ownerName,
    bool isMember = false,
  }) : super(
         id: id,
         name: name,
         description: description,
         logoUrl: logoUrl,
         memberCount: memberCount,
         createdAt: createdAt,
         lastActivity: lastActivity,
         ownerName: ownerName,
         isMember: isMember,
       );

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      logoUrl: json['logoUrl'],
      memberCount: json['memberCount'] ?? 1,
      createdAt: _parseDateTime(json['createdAt']),
      lastActivity: _parseDateTime(json['lastActivity'] ?? json['createdAt']),
      ownerName: json['owner'] != null
          ? (json['owner'] is String ? json['owner'] : json['owner']['name'])
          : null,
      isMember: json['isMember'] ?? false,
    );
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.parse(date);
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
    };
  }
}
