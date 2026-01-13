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

  // Store current user info AND token
  UserEntity? _currentUser;
  String? _currentToken;
  String? _currentTeamId;

  // Track if we're in the process of switching teams
  bool _isSwitchingTeams = false;

  // Add a debounce timer for rapid team switches
  Timer? _teamSwitchDebounceTimer;

  // Store previous team ID for cleanup
  String? _previousTeamId;

  ChatCubit({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.repository,
    required this.userStatusController,
    required this.deleteMessagesUseCase,
  }) : super(const ChatState());

  // ============================================================================
  // CONNECTION MANAGEMENT - IMPROVED
  // ============================================================================

  Future<void> connectToChat(
    String teamId,
    String token,
    UserEntity currentUser, {
    bool forceReconnect = false,
  }) async {
    // Cancel any pending debounce
    _teamSwitchDebounceTimer?.cancel();

    // Debounce rapid team switches (like WhatsApp/Instagram does)
    _teamSwitchDebounceTimer = Timer(
      const Duration(milliseconds: 300),
      () async {
        await _performTeamSwitch(teamId, token, currentUser, forceReconnect);
      },
    );
  }

  Future<void> _performTeamSwitch(
    String teamId,
    String token,
    UserEntity currentUser,
    bool forceReconnect,
  ) async {
    if (_isSwitchingTeams) {
      _logger.i('Already switching teams, skipping...');
      return;
    }

    _isSwitchingTeams = true;

    try {
      // Store previous team ID for cleanup
      _previousTeamId = _currentTeamId;

      // 1. IMMEDIATELY clear UI state to prevent flashing (like WhatsApp)
      if (_currentTeamId != teamId) {
        _logger.i('🔄 Team switch detected: $_currentTeamId -> $teamId');
        emit(
          const ChatState(
            status: ChatStatus.loading,
            messages: [],
            isConnected: false,
            replyingTo: null,
            selectedMessageIds: {},
            isSelectionMode: false,
          ),
        );
      }

      // 2. Store new team info
      _currentUser = currentUser;
      _currentToken = token;
      _currentTeamId = teamId;

      _logger.i('ChatCubit: Connecting to chat for team: $teamId');
      _logger.i('Current user: ${currentUser.name} (${currentUser.id})');

      // 3. Clean up previous subscriptions BEFORE connecting to new team
      await _cleanupPreviousTeamConnection();

      // 4. Update connection status
      emit(state.copyWith(status: ChatStatus.connecting, isConnected: false));

      // 5. Set up listeners BEFORE connecting (important!)
      _setupStreamListeners();

      // 6. Connect to socket
      final result = await repository.connect(teamId, token);

      result.fold(
        (failure) {
          _logger.e('ChatCubit: Connection failed - $failure');
          emit(
            state.copyWith(
              status: ChatStatus.error,
              errorMessage:
                  'Connection failed: ${_mapFailureToMessage(failure)}',
              isConnected: false,
            ),
          );
        },
        (_) {
          _logger.i('ChatCubit: Connection call completed successfully');

          // Immediately update UI with empty state to prevent flashing
          emit(
            state.copyWith(
              status: ChatStatus.loading,
              messages: const [],
              isConnected: repository.isConnected,
            ),
          );

          // Load messages for new team
          _loadTeamMessages(teamId);
        },
      );
    } catch (e) {
      _logger.e('Team switch error: $e');
      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'Failed to switch teams: $e',
        ),
      );
    } finally {
      _isSwitchingTeams = false;
    }
  }

  Future<void> _cleanupPreviousTeamConnection() async {
    _logger.i('🧹 Cleaning up previous team connection...');

    // Cancel all subscriptions
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _userStatusSubscription?.cancel();

    _messageSubscription = null;
    _connectionSubscription = null;
    _userStatusSubscription = null;

    // Only disconnect if we were connected to a different team
    if (_previousTeamId != null && _previousTeamId != _currentTeamId) {
      // Mark user as offline for previous team
      if (_currentUser != null) {
        userStatusController.add(
          UserStatusEvent(
            userId: _currentUser!.id,
            teamId: _previousTeamId!,
            isOnline: false,
          ),
        );
      }

      // Disconnect socket if it's connected to different team
      if (repository.currentTeamId != _currentTeamId &&
          repository.isConnected) {
        await repository.disconnect();
      }
    }
  }

  void _setupStreamListeners() {
    // Listen to connection events
    _connectionSubscription = repository.onConnected.listen(
      (_) {
        _logger.i('ChatCubit: Socket connected event received');
        emit(state.copyWith(isConnected: true, errorMessage: null));
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

    // Listen to messages
    _listenToMessages();

    // Listen to user status
    _listenToUserStatus();
  }

  Future<void> disconnectFromChat() async {
    _logger.i('Disconnecting from chat');

    _teamSwitchDebounceTimer?.cancel();
    _isSwitchingTeams = false;

    if (_currentUser != null && _currentTeamId != null) {
      userStatusController.add(
        UserStatusEvent(
          userId: _currentUser!.id,
          teamId: _currentTeamId!,
          isOnline: false,
        ),
      );
    }

    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _userStatusSubscription?.cancel();

    await repository.disconnect();

    // Clear all state
    _currentTeamId = null;
    _previousTeamId = null;

    emit(
      state.copyWith(
        isConnected: false,
        status: ChatStatus.initial,
        messages: const [],
        selectedMessageIds: const {},
        isSelectionMode: false,
        replyingTo: null,
      ),
    );
  }

  void _joinTeamForOnlineStatus(String teamId) {
    _logger.i('Joining team for online status: $teamId');
    repository.emit('userOnline', {'teamId': teamId});
  }

  // ============================================================================
  // MESSAGE STREAMING - IMPROVED
  // ============================================================================

  void _listenToMessages() {
    _messageSubscription?.cancel();

    _messageSubscription = repository.messageStream.listen(
      (message) {
        // CRITICAL: Filter messages by current team ID
        if (message.teamId != _currentTeamId) {
          _logger.d(
            '⚠️ Ignoring message from different team: ${message.teamId}',
          );
          return;
        }

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

        // Filter events by team ID if available
        final eventTeamId = data['teamId'];
        if (eventTeamId != null && eventTeamId != _currentTeamId) {
          _logger.d('Ignoring event for different team: $eventTeamId');
          return;
        }

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
  // MESSAGE OPERATIONS - IMPROVED
  // ============================================================================

  Future<void> loadMessages(String teamId) async {
    // Verify we're loading messages for the correct team
    if (teamId != _currentTeamId) {
      _logger.w('⚠️ Skipping loadMessages for different team: $teamId');
      return;
    }

    _logger.i('Loading messages for team: $teamId');
    emit(state.copyWith(status: ChatStatus.loading));

    // Use stored token
    if (_currentToken == null) {
      _logger.e('No token available for loading messages');
      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'Not authenticated',
        ),
      );
      return;
    }

    final result = await getMessagesUseCase(teamId, token: _currentToken);

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
        _logger.i('Loaded ${messages.length} messages for team $teamId');

        // IMPORTANT: Sort messages by timestamp (latest at bottom)
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        final processedMessages = messages
            .map(_processIncomingMessage)
            .toList();

        emit(
          state.copyWith(
            status: ChatStatus.loaded,
            messages: processedMessages,
          ),
        );

        // Scroll to bottom after loading
        _scrollToBottomAfterDelay();
      },
    );
  }

  void _loadTeamMessages(String teamId) {
    // Small delay to ensure UI is ready
    Future.delayed(const Duration(milliseconds: 100), () {
      loadMessages(teamId);
    });
  }

  void _scrollToBottomAfterDelay() {
    // This would be called from UI layer, but we add a method hint
    _logger.d('Messages loaded, ready to scroll to bottom');
  }

  Future<void> sendMessage(
    String teamId,
    String content, {
    String? replyToId,
  }) async {
    if (content.trim().isEmpty) return;

    // Verify we're sending to the correct team
    if (teamId != _currentTeamId) {
      _logger.e('Cannot send message to different team: $teamId');
      return;
    }

    _logger.i(
      'Sending message to team $teamId: "$content"${replyToId != null ? ' (reply to: $replyToId)' : ''}',
    );

    // Clear reply
    if (state.replyingTo != null) {
      emit(state.copyWith(replyingTo: null, clearReplyingTo: true));
    }

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

    // Create optimistic message - FIXED: removed hasSender parameter
    final tempMessage = MessageEntity(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      teamId: teamId,
      senderId: _currentUser!.id,
      senderName: 'You',
      content: content.trim(),
      timestamp: DateTime.now(),
      replyToId: replyToId,
    );

    final updatedMessages = [...state.messages, tempMessage];
    emit(
      state.copyWith(
        status: ChatStatus.sending,
        messages: updatedMessages,
        replyingTo: null,
        clearReplyingTo: true,
      ),
    );

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

    // Verify correct team
    if (teamId != _currentTeamId) {
      _logger.e('Cannot delete messages from different team: $teamId');
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
    _logger.i('Setting replyingTo: ${message?.id ?? 'null'}');
    emit(
      state.copyWith(
        replyingTo: message,
        clearReplyingTo: message == null,
        selectedMessageIds: const {},
        isSelectionMode: false,
      ),
    );
  }

  void clearMessages() {
    _logger.i('Clearing messages');
    emit(state.copyWith(messages: const []));
  }

  // New method to clear state for team switch
  void clearStateForTeamSwitch() {
    _logger.i('Clearing state for team switch');
    emit(
      const ChatState(
        status: ChatStatus.loading,
        messages: [],
        isConnected: false,
      ),
    );
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  String _mapFailureToMessage(Failure failure) {
    return failure.toString().replaceAll('Failure: ', '');
  }

  // Getter for current team ID (for debugging)
  String? get currentTeamId => _currentTeamId;

  // Check if we're currently switching teams
  bool get isSwitchingTeams => _isSwitchingTeams;

  @override
  Future<void> close() {
    _logger.i('Closing ChatCubit');
    _teamSwitchDebounceTimer?.cancel();
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _userStatusSubscription?.cancel();
    disconnectFromChat();
    return super.close();
  }
}
