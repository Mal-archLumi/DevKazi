// features/teams/domain/entities/team_entity.dart
class TeamEntity {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final int memberCount;
  final DateTime createdAt;
  final DateTime lastActivity;
  final String? ownerName;
  final bool isMember;

  const TeamEntity({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    required this.memberCount,
    required this.createdAt,
    required this.lastActivity,
    this.ownerName,
    this.isMember = false,
  });

  // Get the first letter of the team name for the avatar
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'T';

  // Add fromJson method
  factory TeamEntity.fromJson(Map<String, dynamic> json) {
    return TeamEntity(
      id: json['id'] ?? json['_id'] ?? '',
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

  TeamEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    int? memberCount,
    DateTime? createdAt,
    DateTime? lastActivity,
    String? ownerName,
    bool? isMember,
  }) {
    return TeamEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      ownerName: ownerName ?? this.ownerName,
      isMember: isMember ?? this.isMember,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TeamEntity &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.logoUrl == logoUrl &&
        other.memberCount == memberCount &&
        other.createdAt == createdAt &&
        other.lastActivity == lastActivity &&
        other.ownerName == ownerName &&
        other.isMember == isMember;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      logoUrl,
      memberCount,
      createdAt,
      lastActivity,
      ownerName,
      isMember,
    );
  }
}
