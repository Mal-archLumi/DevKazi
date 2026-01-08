// lib/features/notifications/data/models/notification_model.dart
import 'package:equatable/equatable.dart';
import 'package:frontend/features/notifications/domain/entities/notification_entity.dart';

class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String? teamId;
  final String? teamName;
  final String? projectId;
  final String? projectTitle;
  final String? triggeredById;
  final String? triggeredByName;
  final String? triggeredByEmail;
  final String? triggeredByPicture;
  final bool isRead;
  final String? actionUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationModel({
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
    this.triggeredByEmail,
    this.triggeredByPicture,
    required this.isRead,
    this.actionUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId']?.toString() ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      teamId: json['teamId']?['_id']?.toString(),
      teamName: json['teamId']?['name']?.toString(),
      projectId: json['projectId']?['_id']?.toString(),
      projectTitle: json['projectId']?['title']?.toString(),
      triggeredById: json['triggeredBy']?['_id']?.toString(),
      triggeredByName: json['triggeredBy']?['name']?.toString(),
      triggeredByEmail: json['triggeredBy']?['email']?.toString(),
      triggeredByPicture: json['triggeredBy']?['picture']?.toString(),
      isRead: json['isRead'] ?? false,
      actionUrl: json['actionUrl']?.toString(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'teamId': teamId,
      'teamName': teamName,
      'projectId': projectId,
      'projectTitle': projectTitle,
      'triggeredById': triggeredById,
      'triggeredByName': triggeredByName,
      'triggeredByPicture': triggeredByPicture,
      'isRead': isRead,
      'actionUrl': actionUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  NotificationEntity toEntity() {
    // Convert string type to NotificationType enum
    NotificationType mapNotificationType(String type) {
      switch (type) {
        case 'join_request':
          return NotificationType.joinRequest;
        case 'join_approved':
          return NotificationType.joinApproved;
        case 'join_rejected':
          return NotificationType.joinRejected;
        case 'project_created':
          return NotificationType.projectCreated;
        case 'project_completed':
          return NotificationType.projectCompleted;
        default:
          return NotificationType.joinRequest;
      }
    }

    return NotificationEntity(
      id: id,
      userId: userId,
      type: mapNotificationType(type),
      title: title,
      message: message,
      teamId: teamId,
      teamName: teamName,
      projectId: projectId,
      projectTitle: projectTitle,
      triggeredById: triggeredById,
      triggeredByName: triggeredByName,
      triggeredByPicture: triggeredByPicture,
      isRead: isRead,
      actionUrl: actionUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

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
}
