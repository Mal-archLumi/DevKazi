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

class ChatCubit extends Cubit<ChatState> {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final ChatRepository repository;
  StreamSubscription? _messageSubscription;
  final Logger _logger = Logger();

  // Store current user info
  UserEntity? _currentUser;
  String? _currentToken;

  ChatCubit({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.repository,
  }) : super(const ChatState());

  void connectToChat(String teamId, String token, UserEntity currentUser) {
    _currentUser = currentUser;
    _currentToken = token;
    _logger.i('ChatCubit: Connecting to chat for team: $teamId');
    _logger.i('Current user: ${currentUser.name} (${currentUser.id})');
    _logger.i('Token length: ${token.length}');

    emit(state.copyWith(status: ChatStatus.connecting));

    repository.connect(teamId, token).then((result) {
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
          _logger.i(
            'ChatCubit: Connection initiated, waiting for authentication...',
          );
          // Don't load messages immediately - wait for proper authentication
          _listenToMessages();

          // Set up authentication listener
          repository.onAuthenticated.listen((_) {
            _logger.i(
              'ChatCubit: Authentication confirmed, loading messages...',
            );
            loadMessages(teamId);
            emit(
              state.copyWith(
                status: ChatStatus.connected,
                isConnected: true,
                errorMessage: null,
              ),
            );
          });
        },
      );
    });
  }

  void _listenToMessages() {
    _messageSubscription = repository.messageStream.listen((message) {
      _logger.d('Received message: ${message.id} from ${message.senderId}');
      // Check if this message is a duplicate of an optimistic message
      final isDuplicate = state.messages.any(
        (existingMsg) =>
            existingMsg.id.startsWith('temp_') &&
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
                  existingMsg.id.startsWith('temp_') &&
                      existingMsg.content == message.content
                  ? _processIncomingMessage(message)
                  : existingMsg,
            )
            .toList();

        emit(
          state.copyWith(messages: updatedMessages, status: ChatStatus.loaded),
        );
      } else {
        _logger.d('Adding new message: ${message.id}');
        // Normal message processing
        final processedMessage = _processIncomingMessage(message);
        final updatedMessages = [...state.messages, processedMessage];
        emit(
          state.copyWith(messages: updatedMessages, status: ChatStatus.loaded),
        );
      }
    });
  }

  MessageEntity _processIncomingMessage(MessageEntity message) {
    // If this message is from current user, update sender name
    if (_currentUser != null && message.senderId == _currentUser!.id) {
      return message.copyWith(senderName: 'You');
    }
    return message;
  }

  void loadMessages(String teamId) {
    _logger.i('Loading messages for team: $teamId');
    emit(state.copyWith(status: ChatStatus.loading));

    getMessagesUseCase(teamId).then((result) {
      result.fold(
        (failure) {
          _logger.e(
            'Failed to load messages: ${_mapFailureToMessage(failure)}',
          );
          emit(
            state.copyWith(
              status: ChatStatus.error,
              errorMessage: _mapFailureToMessage(failure),
            ),
          );
        },
        (messages) {
          _logger.i('Loaded ${messages.length} messages');
          // Process messages to show "You" for current user's messages
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
    });
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

    // Optimistic update with real user data
    final tempMessage = MessageEntity(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      teamId: teamId,
      senderId: _currentUser!.id,
      senderName: 'You', // Will be shown as "You" for current user
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
          // Remove optimistic message on failure
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
          // Success - the real message will come through the stream
          emit(state.copyWith(status: ChatStatus.loaded));
        },
      );
    } catch (e) {
      _logger.e('Exception while sending message: $e');
      // Remove optimistic message on exception
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

  void disconnectFromChat() {
    _logger.i('Disconnecting from chat');
    _messageSubscription?.cancel();
    repository.disconnect();
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
    disconnectFromChat();
    return super.close();
  }
}
