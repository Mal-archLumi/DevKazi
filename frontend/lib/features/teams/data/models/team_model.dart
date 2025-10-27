// data/models/team_model.dart
import '../../domain/entities/team_entity.dart';

class TeamModel extends TeamEntity {
  const TeamModel({
    required super.id,
    required super.name,
    required super.logoUrl,
    required super.initial,
    required super.memberCount,
    required super.createdAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      logoUrl: null, // Always null since we're using initials
      initial: _getInitials(json['name'] ?? ''),
      memberCount: json['memberCount'] ?? 1,
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.parse(date);
    if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
    return DateTime.now();
  }

  static String _getInitials(String name) {
    if (name.isEmpty) return 'T';
    final words = name.trim().split(' ');
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'memberCount': memberCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
