import 'package:frontend/features/chat/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.teamId,
    required super.senderId,
    required super.senderName,
    required super.content,
    required super.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Handle both schema formats (teamId/team, senderId/sender)
    final teamId = json['teamId'] ?? json['team']?.toString() ?? '';
    final senderId = json['senderId'] ?? json['sender']?.toString() ?? '';

    // Handle senderName - use provided name or default
    String senderName;
    if (json['senderName'] != null) {
      senderName = json['senderName'];
    } else if (json['sender'] is Map && json['sender']['name'] != null) {
      senderName = json['sender']['name'];
    } else {
      senderName = 'Unknown';
    }

    // Handle timestamp - could be string, DateTime, or int
    DateTime timestamp;
    if (json['timestamp'] is String) {
      timestamp = DateTime.parse(json['timestamp']);
    } else if (json['timestamp'] is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(json['timestamp']);
    } else if (json['createdAt'] is String) {
      timestamp = DateTime.parse(json['createdAt']);
    } else if (json['createdAt'] is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(json['createdAt']);
    } else {
      timestamp = DateTime.now();
    }

    // Handle ID - could be _id or id
    final id = json['id']?.toString() ?? json['_id']?.toString() ?? '';

    return MessageModel(
      id: id,
      teamId: teamId,
      senderId: senderId,
      senderName: senderName,
      content: json['content']?.toString() ?? '',
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamId': teamId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      teamId: teamId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      timestamp: timestamp,
    );
  }
}
