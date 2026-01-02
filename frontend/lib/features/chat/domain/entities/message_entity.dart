// lib/features/chat/domain/entities/message_entity.dart
import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String teamId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final String? replyToId; // ADD THIS
  final MessageEntity? replyToMessage; // ADD THIS - for hydrated replies

  const MessageEntity({
    required this.id,
    required this.teamId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.replyToId,
    this.replyToMessage,
  });

  MessageEntity copyWith({
    String? id,
    String? teamId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    String? replyToId,
    MessageEntity? replyToMessage,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      replyToId: replyToId ?? this.replyToId,
      replyToMessage: replyToMessage ?? this.replyToMessage,
    );
  }

  // Helper to check if this message is a reply
  bool get isReply => replyToId != null && replyToId!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    teamId,
    senderId,
    senderName,
    content,
    timestamp,
    replyToId,
    replyToMessage,
  ];
}
