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
    // Handle nested user object OR flat user fields
    final userObj = json['user'] as Map<String, dynamic>?;

    return JoinRequestModel(
      id: json['_id'] as String? ?? json['id'] as String,
      teamId: json['team'] is String
          ? json['team'] as String
          : (json['team'] as Map?)?['_id'] as String? ??
                json['teamId'] as String,
      userId: userObj?['_id'] as String? ?? json['userId'] as String,
      userName: userObj?['name'] as String? ?? json['userName'] as String?,
      userEmail: userObj?['email'] as String? ?? json['userEmail'] as String?,
      userPicture:
          userObj?['picture'] as String? ?? json['userPicture'] as String?,
      status: json['status'] as String,
      message: json['message'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
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
