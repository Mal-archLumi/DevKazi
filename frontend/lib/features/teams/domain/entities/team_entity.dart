// domain/entities/team_entity.dart
import 'package:equatable/equatable.dart';

class TeamEntity extends Equatable {
  final String id;
  final String name;
  final String? logoUrl;
  final String initial;
  final int memberCount;
  final DateTime createdAt;

  const TeamEntity({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.initial,
    required this.memberCount,
    required this.createdAt,
  });

  TeamEntity copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? initial,
    int? memberCount,
    DateTime? createdAt,
  }) {
    return TeamEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      initial: initial ?? this.initial,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    logoUrl,
    initial,
    memberCount,
    createdAt,
  ];
}
