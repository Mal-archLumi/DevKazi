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
    // Handle nested team object OR flat teamId field
    String teamId;

    if (json['team'] is Map<String, dynamic>) {
      // If team is a populated object
      final teamObj = json['team'] as Map<String, dynamic>;
      teamId = teamObj['_id']?.toString() ?? teamObj['id']?.toString() ?? '';
    } else if (json['teamId'] is String) {
      // If teamId is a string
      teamId = json['teamId'] as String;
    } else if (json['teamId'] is Map<String, dynamic>) {
      // If teamId is an object (this might be the issue)
      final teamIdObj = json['teamId'] as Map<String, dynamic>;
      teamId =
          teamIdObj['_id']?.toString() ?? teamIdObj['id']?.toString() ?? '';
    } else {
      teamId = '';
    }

    // Handle nested user object OR flat user fields
    final userObj = json['user'] as Map<String, dynamic>?;

    return JoinRequestModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      teamId: teamId, // Use the extracted teamId
      userId: userObj?['_id']?.toString() ?? json['userId']?.toString() ?? '',
      userName: userObj?['name']?.toString() ?? json['userName']?.toString(),
      userEmail: userObj?['email']?.toString() ?? json['userEmail']?.toString(),
      userPicture:
          userObj?['picture']?.toString() ?? json['userPicture']?.toString(),
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
      'id': id,
      'teamId': teamId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPicture': userPicture,
      'status': status,
      'message': message,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
