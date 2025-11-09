// lib/features/chat/domain/entities/message_entity.dart
import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String teamId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final MessageType type;

  const MessageEntity({
    required this.id,
    required this.teamId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
  });

  MessageEntity copyWith({
    String? id,
    String? teamId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    MessageType? type,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [
    id,
    teamId,
    senderId,
    senderName,
    content,
    timestamp,
    type,
  ];
}

enum MessageType { text, image, file }
