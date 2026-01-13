// message_model.dart
import 'package:frontend/features/chat/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.teamId,
    required super.senderId,
    required super.senderName,
    required super.content,
    required super.timestamp,
    super.replyToId,
    super.replyToMessage,
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

    // ✅ KEY FIX: Handle timestamp conversion from UTC to local time
    DateTime parseTimestamp(dynamic timestamp) {
      try {
        if (timestamp is String) {
          // Parse as UTC and convert to local
          final utcTime = DateTime.parse(timestamp).toUtc();
          return utcTime.toLocal();
        } else if (timestamp is int) {
          // Assume milliseconds since epoch in UTC
          return DateTime.fromMillisecondsSinceEpoch(
            timestamp,
            isUtc: true,
          ).toLocal();
        } else {
          return DateTime.now();
        }
      } catch (e) {
        print('⚠️ Error parsing timestamp: $e');
        return DateTime.now();
      }
    }

    // Try multiple timestamp fields
    DateTime timestamp;
    if (json['timestamp'] != null) {
      timestamp = parseTimestamp(json['timestamp']);
    } else if (json['createdAt'] != null) {
      timestamp = parseTimestamp(json['createdAt']);
    } else if (json['sentAt'] != null) {
      timestamp = parseTimestamp(json['sentAt']);
    } else {
      timestamp = DateTime.now();
    }

    // Handle ID - could be _id or id
    final id = json['id']?.toString() ?? json['_id']?.toString() ?? '';

    // Handle replyToId
    final replyToId = json['replyToId']?.toString();

    return MessageModel(
      id: id,
      teamId: teamId,
      senderId: senderId,
      senderName: senderName,
      content: json['content']?.toString() ?? '',
      timestamp: timestamp,
      replyToId: replyToId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamId': teamId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toUtc().toIso8601String(), // ✅ Store as UTC
      if (replyToId != null) 'replyToId': replyToId,
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
      replyToId: replyToId,
    );
  }
}
