// project_entity.dart - FIXED VERSION
import 'package:flutter/material.dart';

class ProjectEntity {
  final String id;
  final String name;
  final String? description;
  final String teamId;
  final String createdBy;
  final String? createdByName;
  final List<ProjectAssignment> assignments;
  final List<TimelinePhase> timeline;
  final List<PinnedLink> pinnedLinks;
  final List<ProjectIdea> ideas;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final double progress;

  const ProjectEntity({
    required this.id,
    required this.name,
    this.description,
    required this.teamId,
    required this.createdBy,
    this.createdByName,
    required this.assignments,
    required this.timeline,
    required this.pinnedLinks,
    required this.ideas,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.progress,
  });

  factory ProjectEntity.fromJson(Map<String, dynamic> json) {
    final assignments =
        (json['assignments'] as List<dynamic>?)
            ?.map((item) => ProjectAssignment.fromJson(item))
            .toList() ??
        [];

    // Calculate progress based on timeline phases
    final timeline =
        (json['timeline'] as List<dynamic>?)
            ?.map((item) => TimelinePhase.fromJson(item))
            .toList() ??
        [];

    final totalPhases = timeline.length;
    final completedPhases = timeline
        .where((phase) => phase.status == 'completed')
        .length;
    final progress = totalPhases > 0 ? completedPhases / totalPhases : 0.0;

    return ProjectEntity(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      description: json['description'],
      teamId: json['teamId'] is String
          ? json['teamId']
          : json['teamId']?['_id'] ?? '',
      createdBy: json['createdBy'] is String
          ? json['createdBy']
          : json['createdBy']?['_id'] ?? '',
      createdByName: json['createdBy'] is Map
          ? json['createdBy']['name']
          : json['createdByName'],
      assignments: assignments,
      timeline: timeline,
      pinnedLinks:
          (json['pinnedLinks'] as List<dynamic>?)
              ?.map((item) => PinnedLink.fromJson(item))
              .toList() ??
          [],
      ideas:
          (json['ideas'] as List<dynamic>?)
              ?.map((item) => ProjectIdea.fromJson(item))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['updated_at']),
      status: json['status'] ?? 'active',
      progress: json['progress']?.toDouble() ?? progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'teamId': teamId,
      'assignments': assignments.map((a) => a.toJson()).toList(),
      'timeline': timeline.map((t) => t.toJson()).toList(),
    };
  }

  ProjectEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? teamId,
    String? createdBy,
    String? createdByName,
    List<ProjectAssignment>? assignments,
    List<TimelinePhase>? timeline,
    List<PinnedLink>? pinnedLinks,
    List<ProjectIdea>? ideas,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    double? progress,
  }) {
    return ProjectEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      teamId: teamId ?? this.teamId,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      assignments: assignments ?? this.assignments,
      timeline: timeline ?? this.timeline,
      pinnedLinks: pinnedLinks ?? this.pinnedLinks,
      ideas: ideas ?? this.ideas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }
}

class ProjectAssignment {
  final String? userId;
  final String role;
  final String tasks;
  final String? assignedTo;
  final String? userName;
  final String? userEmail;
  final String? userAvatar;

  const ProjectAssignment({
    this.userId,
    required this.role,
    required this.tasks,
    this.assignedTo,
    this.userName,
    this.userEmail,
    this.userAvatar,
  });

  factory ProjectAssignment.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map ? json['user'] : null;
    final userId = json['userId'] ?? (user?['_id'] ?? json['user']);

    return ProjectAssignment(
      userId: userId is String && userId.isNotEmpty ? userId : null,
      role: json['role'] ?? '',
      tasks: json['tasks'] ?? '',
      assignedTo:
          json['assignedTo'] ?? '', // FIX: Always get assignedTo from backend
      userName: user?['name'] ?? json['userName'],
      userEmail: user?['email'] ?? json['userEmail'],
      userAvatar: user?['avatar'] ?? json['userAvatar'],
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'role': role,
      'tasks': tasks,
      'assignedTo':
          assignedTo ?? '', // FIX: Always include assignedTo (even if empty)
    };

    // Only include userId if it exists and is not empty
    if (userId != null && userId!.isNotEmpty) {
      json['userId'] = userId!;
    }

    return json;
  }

  ProjectAssignment copyWith({
    String? userId,
    String? role,
    String? tasks,
    String? assignedTo,
    String? userName,
    String? userEmail,
    String? userAvatar,
  }) {
    return ProjectAssignment(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      tasks: tasks ?? this.tasks,
      assignedTo: assignedTo ?? this.assignedTo,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userAvatar: userAvatar ?? this.userAvatar,
    );
  }

  bool get isAssigned => userId != null && userId!.isNotEmpty;

  get id => null;
}

class TimelinePhase {
  final String id;
  final String phase;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  const TimelinePhase({
    required this.id,
    required this.phase,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory TimelinePhase.fromJson(Map<String, dynamic> json) {
    return TimelinePhase(
      id: json['_id'] ?? json['id'] ?? UniqueKey().toString(),
      phase: json['phase'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'] ?? 'planned',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phase': phase,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
    };
  }

  TimelinePhase copyWith({
    String? id,
    String? phase,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) {
    return TimelinePhase(
      id: id ?? this.id,
      phase: phase ?? this.phase,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
    );
  }
}

class PinnedLink {
  final String id;
  final String title;
  final String url;
  final String pinnedBy;
  final String? pinnedByName;
  final DateTime pinnedAt;

  const PinnedLink({
    required this.id,
    required this.title,
    required this.url,
    required this.pinnedBy,
    this.pinnedByName,
    required this.pinnedAt,
  });

  factory PinnedLink.fromJson(Map<String, dynamic> json) {
    final pinnedByUser = json['pinnedBy'] is Map ? json['pinnedBy'] : null;
    return PinnedLink(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      url: json['url'],
      pinnedBy: json['pinnedBy'] is String
          ? json['pinnedBy']
          : pinnedByUser?['_id'] ?? '',
      pinnedByName: pinnedByUser?['name'],
      pinnedAt: DateTime.parse(json['pinnedAt'] ?? json['createdAt']),
    );
  }
}

class ProjectIdea {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final String? createdByName;
  final DateTime createdAt;
  final String status;
  final List<String> upvotes;
  final List<String> downvotes;

  const ProjectIdea({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    this.createdByName,
    required this.createdAt,
    required this.status,
    this.upvotes = const [],
    this.downvotes = const [],
  });

  factory ProjectIdea.fromJson(Map<String, dynamic> json) {
    final createdByUser = json['createdBy'] is Map ? json['createdBy'] : null;
    return ProjectIdea(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      description: json['description'],
      createdBy: json['createdBy'] is String
          ? json['createdBy']
          : createdByUser?['_id'] ?? '',
      createdByName: createdByUser?['name'],
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'] ?? 'pending',
      upvotes: List<String>.from(json['upvotes'] ?? []),
      downvotes: List<String>.from(json['downvotes'] ?? []),
    );
  }
}
