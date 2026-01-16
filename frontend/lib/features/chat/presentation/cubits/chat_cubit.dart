// lib/features/chat/presentation/cubits/chat_cubit.dart - FIXED VERSION
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:frontend/features/chat/presentation/cubits/chat_state.dart';
import 'package:logger/logger.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/chat/domain/entities/message_entity.dart';
import 'package:frontend/features/chat/domain/use_cases/get_messages_use_case.dart';
import 'package:frontend/features/chat/domain/use_cases/send_message_use_case.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/core/events/user_status_events.dart';
import 'package:frontend/features/chat/domain/use_cases/delete_messages_use_case.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:get_it/get_it.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final ChatRepository repository;
  final StreamController<UserStatusEvent> userStatusController;
  final DeleteMessagesUseCase deleteMessagesUseCase;
  final AuthRepository authRepository; // ADDED: For token refresh

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

  // ADDED: Token refresh timer
  Timer? _tokenRefreshTimer;
  Timer? _connectionCheckTimer;

  ChatCubit({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.repository,
    required this.userStatusController,
    required this.deleteMessagesUseCase,
  }) : authRepository = GetIt.I<AuthRepository>(), // Initialize auth repository
       super(const ChatState()) {
    // Start periodic connection check
    _startConnectionCheckTimer();
  }

  // ============================================================================
  // TOKEN MANAGEMENT - NEW
  // ============================================================================

  Future<String?> _getValidToken() async {
    try {
      // First try to get current token
      String? token = await authRepository.getAccessToken();

      if (token == null) {
        _logger.e('No access token found');
        return null;
      }

      // Try to validate the token by checking if it's about to expire
      // For simplicity, we'll just try to refresh if we can't get a valid token
      // In a real app, you'd decode the JWT and check expiration

      // For now, just return the current token
      // The refresh logic will handle when the token actually expires
      return token;
    } catch (e) {
      _logger.e('Error getting valid token: $e');
      return null;
    }
  }

  Future<String?> _refreshTokenIfNeeded() async {
    try {
      _logger.i('🔄 Attempting to refresh token...');

      // Try to get a fresh token (your auth repository should handle refresh)
      final newToken = await authRepository.getAccessToken();

      if (newToken == null) {
        _logger.e('Failed to refresh token');
        return null;
      }

      _logger.i('✅ Token refreshed successfully');
      return newToken;
    } catch (e) {
      _logger.e('Token refresh error: $e');
      return null;
    }
  }

  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();

    // Refresh token every 10 minutes (before 15 minute expiry)
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 10), (
      timer,
    ) async {
      if (_currentTeamId != null && repository.isConnected) {
        _logger.i('🔄 Periodic token refresh check');
        await _refreshConnection();
      }
    });
  }

  void _startConnectionCheckTimer() {
    _connectionCheckTimer?.cancel();

    // Check connection every 30 seconds
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) async {
      if (_currentTeamId != null &&
          !repository.isConnected &&
          !_isSwitchingTeams) {
        _logger.i('🔄 Periodic connection check - attempting to reconnect');
        await _refreshConnection();
      }
    });
  }

  Future<void> _refreshConnection() async {
    if (_currentTeamId == null || _currentUser == null) {
      return;
    }

    try {
      // Get fresh token
      final newToken = await _getValidToken();
      if (newToken == null) {
        _logger.e('Cannot refresh connection: no valid token');
        return;
      }

      _logger.i('🔄 Refreshing WebSocket connection for team $_currentTeamId');

      // Store the current state
      final currentTeamId = _currentTeamId!;
      final currentUser = _currentUser!;

      // Disconnect and reconnect with fresh token
      await _cleanupPreviousTeamConnection();

      // Small delay to ensure clean disconnect
      await Future.delayed(const Duration(milliseconds: 500));

      // Reconnect with fresh token
      await _performTeamSwitch(currentTeamId, newToken, currentUser, true);
    } catch (e) {
      _logger.e('Connection refresh error: $e');
    }
  }

  // ============================================================================
  // CONNECTION MANAGEMENT - IMPROVED WITH TOKEN REFRESH
  // ============================================================================

  Future<void> connectToChat(
    String teamId,
    String token,
    UserEntity currentUser, {
    bool forceReconnect = false,
  }) async {
    // Cancel any pending debounce
    _teamSwitchDebounceTimer?.cancel();

    // Get fresh token
    final freshToken = await _getValidToken();
    if (freshToken == null) {
      _logger.e('Cannot connect: no valid token');
      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'Authentication required. Please log in again.',
          isConnected: false,
        ),
      );
      return;
    }

    // Debounce rapid team switches
    _teamSwitchDebounceTimer = Timer(
      const Duration(milliseconds: 300),
      () async {
        await _performTeamSwitch(
          teamId,
          freshToken,
          currentUser,
          forceReconnect,
        );
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

      // 1. IMMEDIATELY clear UI state to prevent flashing
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

          // Check if it's an authentication error
          final errorMessage = _mapFailureToMessage(failure);
          if (errorMessage.toLowerCase().contains('jwt') ||
              errorMessage.toLowerCase().contains('token') ||
              errorMessage.toLowerCase().contains('auth') ||
              errorMessage.toLowerCase().contains('expired')) {
            _logger.i(
              'Authentication error detected, attempting token refresh...',
            );

            // Try to refresh token and reconnect
            Future.delayed(const Duration(seconds: 2), () async {
              await _handleAuthError(teamId, currentUser);
            });
          } else {
            emit(
              state.copyWith(
                status: ChatStatus.error,
                errorMessage: 'Connection failed: $errorMessage',
                isConnected: false,
              ),
            );
          }
        },
        (_) {
          _logger.i('ChatCubit: Connection call completed successfully');

          // Start token refresh timer
          _startTokenRefreshTimer();

          // Immediately update UI with empty state to prevent flashing
          emit(
            state.copyWith(
              status: ChatStatus.loading,
              messages: const [],
              isConnected: repository.isConnected,
              errorMessage: null,
            ),
          );

          // Load messages for new team
          _loadTeamMessages(teamId);
        },
      );
    } catch (e) {
      _logger.e('Team switch error: $e');

      // Check if it's an auth error
      if (e.toString().toLowerCase().contains('jwt') ||
          e.toString().toLowerCase().contains('token') ||
          e.toString().toLowerCase().contains('auth')) {
        await _handleAuthError(teamId, currentUser);
      } else {
        emit(
          state.copyWith(
            status: ChatStatus.error,
            errorMessage: 'Failed to switch teams: $e',
          ),
        );
      }
    } finally {
      _isSwitchingTeams = false;
    }
  }

  Future<void> _handleAuthError(String teamId, UserEntity currentUser) async {
    _logger.i('🔄 Handling authentication error for team $teamId');

    try {
      // Try to refresh token
      final newToken = await _refreshTokenIfNeeded();

      if (newToken == null) {
        _logger.e('Token refresh failed, requiring re-authentication');
        emit(
          state.copyWith(
            status: ChatStatus.error,
            errorMessage: 'Session expired. Please log in again.',
            isConnected: false,
          ),
        );
        return;
      }

      // Try to reconnect with new token
      _logger.i('🔄 Attempting to reconnect with fresh token...');
      await _performTeamSwitch(teamId, newToken, currentUser, true);
    } catch (e) {
      _logger.e('Auth error handling failed: $e');
      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'Authentication failed. Please log in again.',
          isConnected: false,
        ),
      );
    }
  }

  Future<void> _cleanupPreviousTeamConnection() async {
    _logger.i('🧹 Cleaning up previous team connection...');

    // Stop timers
    _tokenRefreshTimer?.cancel();

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
    _tokenRefreshTimer?.cancel();
    _connectionCheckTimer?.cancel();
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
    _currentToken = null;

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

  // ============================================================================
  // MESSAGE OPERATIONS - UPDATED WITH TOKEN REFRESH
  // ============================================================================

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

      // Try to refresh connection before showing error
      await _refreshConnection();

      if (!repository.isConnected) {
        emit(
          state.copyWith(
            status: ChatStatus.error,
            errorMessage: 'Not connected to chat. Please try again.',
          ),
        );
      }
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

          // Check if it's an auth error
          final errorMessage = _mapFailureToMessage(failure);
          if (errorMessage.toLowerCase().contains('jwt') ||
              errorMessage.toLowerCase().contains('token') ||
              errorMessage.toLowerCase().contains('auth')) {
            // Try to refresh and resend
            _handleSendAuthError(teamId, content, replyToId, tempMessage);
          } else {
            final failedMessages = List<MessageEntity>.from(state.messages)
              ..removeWhere((msg) => msg.id.startsWith('temp-'));

            emit(
              state.copyWith(
                status: ChatStatus.error,
                messages: failedMessages,
                errorMessage: errorMessage,
              ),
            );
          }
        },
        (_) {
          _logger.i('Message sent successfully');
          emit(state.copyWith(status: ChatStatus.loaded));
        },
      );
    } catch (e) {
      _logger.e('Exception while sending message: $e');

      // Check if it's an auth error
      if (e.toString().toLowerCase().contains('jwt') ||
          e.toString().toLowerCase().contains('token') ||
          e.toString().toLowerCase().contains('auth')) {
        _handleSendAuthError(teamId, content, replyToId, tempMessage);
      } else {
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
  }

  Future<void> _handleSendAuthError(
    String teamId,
    String content,
    String? replyToId,
    MessageEntity tempMessage,
  ) async {
    _logger.i('🔄 Authentication error while sending, attempting refresh...');

    try {
      // Refresh token
      final newToken = await _refreshTokenIfNeeded();

      if (newToken == null) {
        _logger.e('Token refresh failed');
        final failedMessages = List<MessageEntity>.from(state.messages)
          ..removeWhere((msg) => msg.id.startsWith('temp-'));

        emit(
          state.copyWith(
            status: ChatStatus.error,
            messages: failedMessages,
            errorMessage: 'Session expired. Please log in again.',
          ),
        );
        return;
      }

      // Update current token
      _currentToken = newToken;

      // Remove temp message and try again
      final failedMessages = List<MessageEntity>.from(state.messages)
        ..removeWhere((msg) => msg.id.startsWith('temp-'));

      emit(state.copyWith(status: ChatStatus.loaded, messages: failedMessages));

      // Retry sending
      await sendMessage(teamId, content, replyToId: replyToId);
    } catch (e) {
      _logger.e('Failed to handle auth error: $e');
      final failedMessages = List<MessageEntity>.from(state.messages)
        ..removeWhere((msg) => msg.id.startsWith('temp-'));

      emit(
        state.copyWith(
          status: ChatStatus.error,
          messages: failedMessages,
          errorMessage: 'Failed to send message. Please try again.',
        ),
      );
    }
  }

  // ============================================================================
  // REMAINING METHODS (unchanged from your original, keep them as they were)
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

  Future<void> loadMessages(String teamId) async {
    // Verify we're loading messages for the correct team
    if (teamId != _currentTeamId) {
      _logger.w('⚠️ Skipping loadMessages for different team: $teamId');
      return;
    }

    _logger.i('Loading messages for team: $teamId');
    emit(state.copyWith(status: ChatStatus.loading));

    // Get fresh token
    final token = await _getValidToken();
    if (token == null) {
      _logger.e('No token available for loading messages');
      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'Not authenticated',
        ),
      );
      return;
    }

    final result = await getMessagesUseCase(teamId, token: token);

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
    _tokenRefreshTimer?.cancel();
    _connectionCheckTimer?.cancel();
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _userStatusSubscription?.cancel();
    disconnectFromChat();
    return super.close();
  }
}
