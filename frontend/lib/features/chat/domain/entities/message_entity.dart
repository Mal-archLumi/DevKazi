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
