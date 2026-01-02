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

class SelectedMessage {
  final MessageEntity message;
  final bool isSelected;

  SelectedMessage({required this.message, this.isSelected = false});
}

class ChatState {
  final ChatStatus status;
  final List<MessageEntity> messages;
  final String? errorMessage;
  final bool isConnected;
  final int unreadCount;
  final Set<String> selectedMessageIds;
  final MessageEntity? replyingTo;
  final bool isSelectionMode;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
    this.isConnected = false,
    this.unreadCount = 0,
    this.selectedMessageIds = const {},
    this.replyingTo,
    this.isSelectionMode = false,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<MessageEntity>? messages,
    String? errorMessage,
    bool? isConnected,
    int? unreadCount,
    Set<String>? selectedMessageIds,
    MessageEntity? replyingTo,
    bool? isSelectionMode,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
      isConnected: isConnected ?? this.isConnected,
      unreadCount: unreadCount ?? this.unreadCount,
      selectedMessageIds: selectedMessageIds ?? this.selectedMessageIds,
      replyingTo: replyingTo ?? this.replyingTo,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  List<MessageEntity> get selectedMessages => messages
      .where((message) => selectedMessageIds.contains(message.id))
      .toList();

  bool isMessageSelected(String messageId) =>
      selectedMessageIds.contains(messageId);
}
