// lib/features/chat/presentation/cubits/chat_state.dart
import 'package:frontend/features/chat/domain/entities/message_entity.dart';

enum ChatStatus {
  initial,
  connecting,
  connected,
  loading,
  loaded,
  error,
  sending,
  disconnected,
}

class ChatState {
  final ChatStatus status;
  final List<MessageEntity> messages;
  final String? errorMessage;
  final bool isConnected;
  final int unreadCount;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
    this.isConnected = false,
    this.unreadCount = 0,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<MessageEntity>? messages,
    String? errorMessage,
    bool? isConnected,
    int? unreadCount,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
      isConnected: isConnected ?? this.isConnected,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
