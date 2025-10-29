// domain/entities/team_entity.dart
import 'package:equatable/equatable.dart';

class TeamEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final int memberCount;
  final DateTime createdAt;
  final bool isMember;

  const TeamEntity({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    required this.memberCount,
    required this.createdAt,
    this.isMember = false,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'T';

  TeamEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    int? memberCount,
    DateTime? createdAt,
    bool? isMember,
  }) {
    return TeamEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
      isMember: isMember ?? this.isMember,
    );
  }

  factory TeamEntity.fromJson(Map<String, dynamic> json) {
    return TeamEntity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      logoUrl: json['logoUrl'],
      memberCount: json['memberCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      isMember: json['isMember'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    logoUrl,
    memberCount,
    createdAt,
    isMember,
  ];
}
