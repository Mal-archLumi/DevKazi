// lib/features/notifications/domain/entities/notification_entity.dart

import 'package:equatable/equatable.dart';

enum NotificationType {
  joinRequest,
  joinApproved,
  joinRejected,
  projectCreated,
  projectCompleted,
}

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final String? teamId;
  final String? teamName;
  final String? projectId;
  final String? projectTitle;
  final String? triggeredById;
  final String? triggeredByName;
  final String? triggeredByPicture;
  final bool isRead;
  final String? actionUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.teamId,
    this.teamName,
    this.projectId,
    this.projectTitle,
    this.triggeredById,
    this.triggeredByName,
    this.triggeredByPicture,
    required this.isRead,
    this.actionUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    title,
    message,
    teamId,
    teamName,
    projectId,
    projectTitle,
    triggeredById,
    triggeredByName,
    triggeredByPicture,
    isRead,
    actionUrl,
    createdAt,
    updatedAt,
  ];

  NotificationEntity copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    String? teamId,
    String? teamName,
    String? projectId,
    String? projectTitle,
    String? triggeredById,
    String? triggeredByName,
    String? triggeredByPicture,
    bool? isRead,
    String? actionUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      projectId: projectId ?? this.projectId,
      projectTitle: projectTitle ?? this.projectTitle,
      triggeredById: triggeredById ?? this.triggeredById,
      triggeredByName: triggeredByName ?? this.triggeredByName,
      triggeredByPicture: triggeredByPicture ?? this.triggeredByPicture,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
