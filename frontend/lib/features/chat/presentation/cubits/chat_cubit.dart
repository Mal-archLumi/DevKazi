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
import 'package:frontend/core/events/user_status_events.dart'; // ADD THIS

// REMOVE THIS DUPLICATE CLASS - it's now in the shared file
// class UserStatusEvent {
//   final String userId;
//   final String teamId;
//   final bool isOnline;
//
//   UserStatusEvent({
//     required this.userId,
//     required this.teamId,
//     required this.isOnline,
//   });
// }

class ChatCubit extends Cubit<ChatState> {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final ChatRepository repository;
  final StreamController<UserStatusEvent> userStatusController;
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
  }) : super(const ChatState());

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

    // NEW: Immediately set current user as online
    userStatusController.add(
      UserStatusEvent(userId: currentUser.id, teamId: teamId, isOnline: true),
    );

    emit(state.copyWith(status: ChatStatus.connecting));

    // Listen to connection events BEFORE connecting
    _connectionSubscription = repository.onConnected.listen(
      (_) {
        _logger.i('ChatCubit: Socket connected event received');

        // Join team for online status
        _joinTeamForOnlineStatus(teamId);

        // Connection confirmed, now load messages
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
        // If already connected (synchronous connection), load messages immediately
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
          // Replace the optimistic message with the real one
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
          // Normal message processing
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
        _logger.d(
          'User status update: ${data['userId']} is ${data['isOnline'] ? 'online' : 'offline'}',
        );

        _handleUserStatusUpdate(data);
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

    // Emit event to TeamDetailsCubit
    userStatusController.add(
      UserStatusEvent(userId: userId, teamId: teamId, isOnline: isOnline),
    );
  }

  void _joinTeamForOnlineStatus(String teamId) {
    _logger.i('Joining team for online status: $teamId');
    repository.emit('userOnline', {'teamId': teamId});
  }

  MessageEntity _processIncomingMessage(MessageEntity message) {
    if (_currentUser != null && message.senderId == _currentUser!.id) {
      return message.copyWith(senderName: 'You');
    }
    return message;
  }

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

  void addOptimisticMessage(MessageEntity msg) {
    _logger.d('Adding optimistic message: ${msg.id}');
    emit(
      state.copyWith(
        messages: [...state.messages, msg],
        status: ChatStatus.sending,
      ),
    );
  }

  Future<void> sendMessage(String teamId, String content) async {
    if (content.trim().isEmpty) return;

    _logger.i('Sending message to team $teamId: "$content"');

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

    _logger.i('Preparing to send message to team $teamId: "${content.trim()}"');

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
      final result = await sendMessageUseCase(teamId, content.trim());

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

  void clearMessages() {
    _logger.i('Clearing messages');
    emit(state.copyWith(messages: const []));
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
