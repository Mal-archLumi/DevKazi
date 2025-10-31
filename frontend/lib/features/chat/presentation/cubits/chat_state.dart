// lib/features/chat/presentation/cubits/chat_state.dart
import 'package:frontend/features/chat/domain/entities/message_entity.dart';

enum ChatStatus { initial, loading, loaded, error, sending }

class ChatState {
  final ChatStatus status;
  final List<MessageEntity> messages;
  final String? errorMessage;
  final bool isConnected;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
    this.isConnected = false,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<MessageEntity>? messages,
    String? errorMessage,
    bool? isConnected,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
