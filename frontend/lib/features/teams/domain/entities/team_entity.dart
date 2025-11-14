// features/teams/domain/entities/team_entity.dart
import 'package:equatable/equatable.dart';

class TeamEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final int memberCount;
  final DateTime createdAt;
  final DateTime lastActivity;
  final String? ownerName;
  final bool isMember;
  final String? inviteCode;
  final List<TeamMember> members;

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
    this.inviteCode,
    this.members = const [],
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'T';

  factory TeamEntity.fromJson(Map<String, dynamic> json) {
    print('🟡 TeamEntity.fromJson: Parsing team data');
    print('🟡 TeamEntity.fromJson: Members data: ${json['members']}');

    return TeamEntity(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      logoUrl: json['logoUrl'],
      memberCount:
          json['memberCount'] ??
          (json['members'] != null ? (json['members'] as List).length : 1),
      createdAt: _parseDateTime(json['createdAt']),
      lastActivity: _parseDateTime(json['lastActivity'] ?? json['createdAt']),
      ownerName: json['owner'] != null
          ? (json['owner'] is String ? json['owner'] : json['owner']['name'])
          : null,
      isMember: json['isMember'] ?? false,
      inviteCode: json['inviteCode'],
      members: _parseMembers(json['members']),
    );
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.parse(date);
    if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
    return DateTime.now();
  }

  static List<TeamMember> _parseMembers(dynamic membersData) {
    print('🟡 _parseMembers: Raw members data: $membersData');

    if (membersData == null) {
      print('🔴 _parseMembers: membersData is null');
      return [];
    }
    if (membersData is! List) {
      print(
        '🔴 _parseMembers: membersData is not a List, type: ${membersData.runtimeType}',
      );
      return [];
    }

    final members = membersData.map((memberJson) {
      print('🟡 _parseMembers: Parsing member: $memberJson');
      return TeamMember.fromJson(memberJson);
    }).toList();

    print('🟢 _parseMembers: Successfully parsed ${members.length} members');
    return members;
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
    String? inviteCode,
    List<TeamMember>? members,
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
      inviteCode: inviteCode ?? this.inviteCode,
      members: members ?? this.members,
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
    lastActivity,
    ownerName,
    isMember,
    inviteCode,
    members,
  ];
}

class TeamMember extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? role;
  final DateTime joinedAt;
  final bool isOnline;

  const TeamMember({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    required this.joinedAt,
    this.isOnline = false,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    print('🟡 TeamMember.fromJson: Parsing member: $json');

    final member = TeamMember(
      id: json['user']?['_id'] ?? json['user']?['id'] ?? '',
      name: json['user']?['name'] ?? 'Unknown User',
      email: json['user']?['email'] ?? '',
      role: json['role'],
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
      isOnline: json['isOnline'] ?? false, // ADDED: Online status from API
    );

    print(
      '🟢 TeamMember.fromJson: Created member: ${member.name} (${member.email}) - Online: ${member.isOnline}',
    );
    return member;
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name;
  }

  @override
  List<Object?> get props => [id, name, email, role, joinedAt, isOnline];
}
