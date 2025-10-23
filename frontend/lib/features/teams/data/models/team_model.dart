// data/models/team_model.dart
import 'package:equatable/equatable.dart';
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
      id: json['id'],
      name: json['name'],
      logoUrl: json['logo_url'],
      initial: json['initial'] ?? _getInitials(json['name']),
      memberCount: json['member_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static String _getInitials(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : 'T';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'initial': initial,
      'member_count': memberCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
