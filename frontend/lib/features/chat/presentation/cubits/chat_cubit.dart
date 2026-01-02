// lib/features/chat/presentation/cubits/chat_cubit.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/chat/domain/entities/message_entity.dart';
import 'package:frontend/features/chat/domain/use_cases/get_messages_use_case.dart';
import 'package:frontend/features/chat/domain/use_cases/send_message_use_case.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'chat_state.dart';
import 'package:frontend/core/events/user_status_events.dart';
import 'package:frontend/features/chat/domain/use_cases/delete_messages_use_case.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final ChatRepository repository;
  final StreamController<UserStatusEvent> userStatusController;
  final DeleteMessagesUseCase deleteMessagesUseCase;

  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _userStatusSubscription;

  final Logger _logger = Logger();

  // Store current user info
  UserEntity? _currentUser;
  String? _currentToken;

  ChatCubit({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.repository,
    required this.userStatusController,
    required this.deleteMessagesUseCase,
  }) : super(const ChatState());

  // ============================================================================
  // CONNECTION MANAGEMENT
  // ============================================================================

  Future<void> connectToChat(
    String teamId,
    String token,
    UserEntity currentUser,
  ) async {
    _currentUser = currentUser;
    _currentToken = token;
    _logger.i('ChatCubit: Connecting to chat for team: $teamId');
    _logger.i('Current user: ${currentUser.name} (${currentUser.id})');
    _logger.i('Token length: ${token.length}');

    // Immediately set current user as online
    userStatusController.add(
      UserStatusEvent(userId: currentUser.id, teamId: teamId, isOnline: true),
    );

    emit(state.copyWith(status: ChatStatus.connecting));

    // Listen to connection events BEFORE connecting
    _connectionSubscription = repository.onConnected.listen(
      (_) {
        _logger.i('ChatCubit: Socket connected event received');
        _joinTeamForOnlineStatus(teamId);
        loadMessages(teamId);
        emit(
          state.copyWith(
            status: ChatStatus.connected,
            isConnected: true,
            errorMessage: null,
          ),
        );
      },
      onError: (error) {
        _logger.e('ChatCubit: Connection stream error - $error');
        emit(
          state.copyWith(
            status: ChatStatus.error,
            errorMessage: 'Connection error: $error',
            isConnected: false,
          ),
        );
      },
    );

    // Start listening to messages AND user status
    _listenToMessages();
    _listenToUserStatus();

    // Connect to socket
    final result = await repository.connect(teamId, token);

    result.fold(
      (failure) {
        _logger.e('ChatCubit: Connection failed - $failure');
        emit(
          state.copyWith(
            status: ChatStatus.error,
            errorMessage: 'Connection failed: ${_mapFailureToMessage(failure)}',
            isConnected: false,
          ),
        );
        _connectionSubscription?.cancel();
        _userStatusSubscription?.cancel();
      },
      (_) {
        _logger.i('ChatCubit: Connection call completed successfully');
        if (repository.isConnected) {
          _logger.i(
            'ChatCubit: Socket already connected, loading messages immediately',
          );
          _joinTeamForOnlineStatus(teamId);
          loadMessages(teamId);
          emit(
            state.copyWith(
              status: ChatStatus.connected,
              isConnected: true,
              errorMessage: null,
            ),
          );
        } else {
          _logger.i('ChatCubit: Waiting for connection confirmation...');
        }
      },
    );
  }

  Future<void> disconnectFromChat() async {
    _logger.i('Disconnecting from chat');

    if (_currentUser != null) {
      userStatusController.add(
        UserStatusEvent(userId: _currentUser!.id, teamId: '', isOnline: false),
      );
    }

    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _userStatusSubscription?.cancel();
    await repository.disconnect();
    _currentUser = null;
    _currentToken = null;
    emit(
      state.copyWith(
        isConnected: false,
        status: ChatStatus.initial,
        messages: const [],
      ),
    );
  }

  void _joinTeamForOnlineStatus(String teamId) {
    _logger.i('Joining team for online status: $teamId');
    repository.emit('userOnline', {'teamId': teamId});
  }

  // ============================================================================
  // MESSAGE STREAMING
  // ============================================================================

  void _listenToMessages() {
    _messageSubscription?.cancel();

    _messageSubscription = repository.messageStream.listen(
      (message) {
        _logger.d('Received message: ${message.id} from ${message.senderId}');

        // Check if this message is a duplicate of an optimistic message
        final isDuplicate = state.messages.any(
          (existingMsg) =>
              existingMsg.id.startsWith('temp-') &&
              existingMsg.content == message.content &&
              existingMsg.timestamp
                      .difference(message.timestamp)
                      .inSeconds
                      .abs() <
                  5,
        );

        if (isDuplicate) {
          _logger.d(
            'Replacing optimistic message with real message: ${message.id}',
          );
          final updatedMessages = state.messages
              .map(
                (existingMsg) =>
                    existingMsg.id.startsWith('temp-') &&
                        existingMsg.content == message.content
                    ? _processIncomingMessage(message)
                    : existingMsg,
              )
              .toList();

          emit(
            state.copyWith(
              messages: updatedMessages,
              status: ChatStatus.loaded,
            ),
          );
        } else {
          _logger.d('Adding new message: ${message.id}');
          final processedMessage = _processIncomingMessage(message);
          final updatedMessages = [...state.messages, processedMessage];
          emit(
            state.copyWith(
              messages: updatedMessages,
              status: ChatStatus.loaded,
            ),
          );
        }
      },
      onError: (error) {
        _logger.e('Message stream error: $error');
      },
    );
  }

  void _listenToUserStatus() {
    _userStatusSubscription?.cancel();

    _userStatusSubscription = repository.userStatusStream.listen(
      (data) {
        _logger.d('Received status/event data: $data');

        // Handle messages_deleted event
        if (data['type'] == 'messages_deleted' || data['messageIds'] != null) {
          _logger.i('📨 Received messages_deleted event');
          final messageIds = List<String>.from(data['messageIds'] ?? []);
          if (messageIds.isNotEmpty) {
            _removeDeletedMessages(messageIds);
          }
        }
        // Handle user status updates
        else if (data['userId'] != null && data['isOnline'] != null) {
          _handleUserStatusUpdate(data);
        }
      },
      onError: (error) {
        _logger.e('User status stream error: $error');
      },
    );
  }

  void _handleUserStatusUpdate(Map<String, dynamic> data) {
    final userId = data['userId'];
    final isOnline = data['isOnline'];
    final teamId = data['teamId'];

    _logger.i(
      'User status: $userId is ${isOnline ? 'online' : 'offline'} in team $teamId',
    );

    userStatusController.add(
      UserStatusEvent(userId: userId, teamId: teamId, isOnline: isOnline),
    );
  }

  MessageEntity _processIncomingMessage(MessageEntity message) {
    if (_currentUser != null && message.senderId == _currentUser!.id) {
      return message.copyWith(senderName: 'You');
    }
    return message;
  }

  // ============================================================================
  // MESSAGE OPERATIONS
  // ============================================================================

  Future<void> loadMessages(String teamId) async {
    _logger.i('Loading messages for team: $teamId');
    emit(state.copyWith(status: ChatStatus.loading));

    final result = await getMessagesUseCase(teamId);

    result.fold(
      (failure) {
        _logger.e('Failed to load messages: ${_mapFailureToMessage(failure)}');
        emit(
          state.copyWith(
            status: ChatStatus.error,
            errorMessage: _mapFailureToMessage(failure),
          ),
        );
      },
      (messages) {
        _logger.i('Loaded ${messages.length} messages');
        final processedMessages = messages
            .map(_processIncomingMessage)
            .toList();
        emit(
          state.copyWith(
            status: ChatStatus.loaded,
            messages: processedMessages,
          ),
        );
      },
    );
  }

  Future<void> sendMessage(
    String teamId,
    String content, {
    String? replyToId,
  }) async {
    if (content.trim().isEmpty) return;

    _logger.i(
      'Sending message to team $teamId: "$content"${replyToId != null ? ' (reply to: $replyToId)' : ''}',
    );

    // Clear reply immediately when sending
    emit(state.copyWith(replyingTo: null));

    if (!repository.isConnected) {
      _logger.e('Cannot send message - socket not connected');
      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'Not connected to chat',
        ),
      );
      return;
    }

    if (_currentUser == null) {
      _logger.e('Cannot send message - user not authenticated');
      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'User not authenticated',
        ),
      );
      return;
    }

    // Create optimistic message
    final tempMessage = MessageEntity(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      teamId: teamId,
      senderId: _currentUser!.id,
      senderName: 'You',
      content: content.trim(),
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...state.messages, tempMessage];
    emit(state.copyWith(status: ChatStatus.sending, messages: updatedMessages));

    try {
      final result = await sendMessageUseCase(
        teamId,
        content.trim(),
        replyToId: replyToId,
      );

      result.fold(
        (failure) {
          _logger.e('Error sending message: ${_mapFailureToMessage(failure)}');
          final failedMessages = List<MessageEntity>.from(state.messages)
            ..removeWhere((msg) => msg.id.startsWith('temp-'));

          emit(
            state.copyWith(
              status: ChatStatus.error,
              messages: failedMessages,
              errorMessage: _mapFailureToMessage(failure),
            ),
          );
        },
        (_) {
          _logger.i('Message sent successfully');
          emit(state.copyWith(status: ChatStatus.loaded));
        },
      );
    } catch (e) {
      _logger.e('Exception while sending message: $e');
      final failedMessages = List<MessageEntity>.from(state.messages)
        ..removeWhere((msg) => msg.id.startsWith('temp-'));

      emit(
        state.copyWith(
          status: ChatStatus.error,
          messages: failedMessages,
          errorMessage: 'Failed to send message',
        ),
      );
    }
  }

  Future<void> deleteSelectedMessages(String teamId) async {
    if (state.selectedMessageIds.isEmpty) {
      _logger.w('No messages selected for deletion');
      return;
    }

    _logger.i('🗑️ Deleting ${state.selectedMessageIds.length} messages');

    try {
      final messageIds = state.selectedMessageIds.toList();
      _logger.d('Message IDs: ${messageIds.join(", ")}');

      // Optimistically remove messages from UI
      final remainingMessages = state.messages
          .where((msg) => !state.selectedMessageIds.contains(msg.id))
          .toList();

      emit(
        state.copyWith(
          messages: remainingMessages,
          selectedMessageIds: const {},
          isSelectionMode: false,
          status: ChatStatus.sending,
        ),
      );

      _logger.i('🔄 Calling deleteMessagesUseCase...');
      final result = await deleteMessagesUseCase(teamId, messageIds);

      result.fold(
        (failure) {
          _logger.e(
            '❌ Failed to delete messages: ${_mapFailureToMessage(failure)}',
          );

          // Reload messages to restore correct state
          _logger.i('🔄 Reloading messages after delete failure...');
          loadMessages(teamId);

          emit(
            state.copyWith(
              status: ChatStatus.error,
              errorMessage:
                  'Failed to delete messages: ${_mapFailureToMessage(failure)}',
            ),
          );
        },
        (_) {
          _logger.i('✅ Messages deleted successfully');
          emit(state.copyWith(status: ChatStatus.loaded));
        },
      );
    } catch (e) {
      _logger.e('💥 Exception while deleting messages: $e');

      // Reload messages to restore correct state
      _logger.i('🔄 Reloading messages after exception...');
      loadMessages(teamId);

      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'Failed to delete messages: $e',
        ),
      );
    }
  }

  void _removeDeletedMessages(List<String> deletedMessageIds) {
    _logger.i(
      '🗑️ Removing ${deletedMessageIds.length} deleted messages from UI',
    );
    _logger.d('Message IDs to remove: ${deletedMessageIds.join(", ")}');

    final remainingMessages = state.messages
        .where((msg) => !deletedMessageIds.contains(msg.id))
        .toList();

    final remainingSelectedIds = state.selectedMessageIds
        .where((id) => !deletedMessageIds.contains(id))
        .toSet();

    _logger.i(
      'Messages before: ${state.messages.length}, after: ${remainingMessages.length}',
    );

    emit(
      state.copyWith(
        messages: remainingMessages,
        selectedMessageIds: remainingSelectedIds,
        isSelectionMode: remainingSelectedIds.isNotEmpty,
      ),
    );
  }

  // ============================================================================
  // UI STATE MANAGEMENT
  // ============================================================================

  void toggleMessageSelection(String messageId) {
    final newSelectedIds = Set<String>.from(state.selectedMessageIds);

    if (newSelectedIds.contains(messageId)) {
      newSelectedIds.remove(messageId);
    } else {
      newSelectedIds.add(messageId);
    }

    emit(
      state.copyWith(
        selectedMessageIds: newSelectedIds,
        isSelectionMode: newSelectedIds.isNotEmpty,
      ),
    );
  }

  void selectAllMessages() {
    final allMessageIds = state.messages.map((msg) => msg.id).toSet();
    emit(
      state.copyWith(selectedMessageIds: allMessageIds, isSelectionMode: true),
    );
  }

  void clearSelection() {
    emit(
      state.copyWith(
        selectedMessageIds: const {},
        isSelectionMode: false,
        replyingTo: null,
      ),
    );
  }

  void setReplyingTo(MessageEntity? message) {
    emit(
      state.copyWith(
        replyingTo: message,
        selectedMessageIds: const {},
        isSelectionMode: false,
      ),
    );
  }

  void clearMessages() {
    _logger.i('Clearing messages');
    emit(state.copyWith(messages: const []));
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  String _mapFailureToMessage(Failure failure) {
    return failure.toString().replaceAll('Failure: ', '');
  }

  @override
  Future<void> close() {
    _logger.i('Closing ChatCubit');
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _userStatusSubscription?.cancel();
    disconnectFromChat();
    return super.close();
  }
}
