// data/models/join_request_model.dart
import 'package:frontend/features/teams/domain/entities/join_request_entity.dart';

class JoinRequestModel extends JoinRequestEntity {
  const JoinRequestModel({
    required super.id,
    required super.teamId,
    required super.userId,
    super.userName,
    super.userEmail,
    super.userPicture,
    required super.status,
    super.message,
    super.createdAt,
    super.updatedAt,
  });

  factory JoinRequestModel.fromJson(Map<String, dynamic> json) {
    // Handle nested user object
    final user = json['userId'] is Map
        ? json['userId'] as Map<String, dynamic>
        : null;

    return JoinRequestModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      teamId: json['teamId'] is Map
          ? json['teamId']['_id']?.toString() ?? ''
          : json['teamId']?.toString() ?? '',
      userId: user != null
          ? user['_id']?.toString() ?? ''
          : json['userId']?.toString() ?? '',
      userName: user?['name']?.toString(),
      userEmail: user?['email']?.toString(),
      userPicture: user?['picture']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      message: json['message']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'teamId': teamId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'status': status,
      'message': message,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
