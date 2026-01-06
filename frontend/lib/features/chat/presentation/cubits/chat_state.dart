// lib/features/chat/presentation/cubits/chat_state.dart
import 'package:equatable/equatable.dart';
import 'package:frontend/features/chat/domain/entities/message_entity.dart';

enum ChatStatus {
  initial,
  connecting,
  connected,
  loading,
  loaded,
  sending,
  error,
}

class ChatState extends Equatable {
  final ChatStatus status;
  final List<MessageEntity> messages;
  final String? errorMessage;
  final bool isConnected;
  final MessageEntity? replyingTo;
  final Set<String> selectedMessageIds;
  final bool isSelectionMode;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
    this.isConnected = false,
    this.replyingTo,
    this.selectedMessageIds = const {},
    this.isSelectionMode = false,
  });

  bool isMessageSelected(String messageId) =>
      selectedMessageIds.contains(messageId);

  ChatState copyWith({
    ChatStatus? status,
    List<MessageEntity>? messages,
    String? errorMessage,
    bool? isConnected,
    MessageEntity? replyingTo,
    bool clearReplyingTo = false, // Add this flag
    Set<String>? selectedMessageIds,
    bool? isSelectionMode,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
      isConnected: isConnected ?? this.isConnected,
      // If clearReplyingTo is true, set to null; otherwise use provided value or keep current
      replyingTo: clearReplyingTo ? null : (replyingTo ?? this.replyingTo),
      selectedMessageIds: selectedMessageIds ?? this.selectedMessageIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    messages,
    errorMessage,
    isConnected,
    replyingTo,
    selectedMessageIds,
    isSelectionMode,
  ];
}
