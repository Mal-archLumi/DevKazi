// domain/entities/join_request_entity.dart
import 'package:equatable/equatable.dart';

class JoinRequestEntity extends Equatable {
  final String id;
  final String teamId;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String? userPicture;
  final String status; // 'pending', 'approved', 'rejected'
  final String? message;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const JoinRequestEntity({
    required this.id,
    required this.teamId,
    required this.userId,
    this.userName,
    this.userEmail,
    this.userPicture,
    required this.status,
    this.message,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    teamId,
    userId,
    userName,
    userEmail,
    userPicture,
    status,
    message,
    createdAt,
    updatedAt,
  ];

  get avatarUrl => null;

  get skills => null;

  JoinRequestEntity copyWith({
    String? id,
    String? teamId,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPicture,
    String? status,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JoinRequestEntity(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPicture: userPicture ?? this.userPicture,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
