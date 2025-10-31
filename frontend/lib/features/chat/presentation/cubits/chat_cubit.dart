// lib/features/chat/presentation/cubits/chat_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:frontend/features/chat/domain/entities/message_entity.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(const ChatState());

  void loadMessages(String teamId) {
    emit(state.copyWith(status: ChatStatus.loading));

    // TODO: Implement real message loading
    final mockMessages = [
      MessageEntity(
        id: '1',
        teamId: teamId,
        senderId: 'user1',
        senderName: 'John Doe',
        content: 'Hello team!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      MessageEntity(
        id: '2',
        teamId: teamId,
        senderId: 'user2',
        senderName: 'Jane Smith',
        content: 'Hi everyone!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
    ];

    emit(state.copyWith(status: ChatStatus.loaded, messages: mockMessages));
  }

  void sendMessage(String teamId, String content) {
    if (content.trim().isEmpty) return;

    emit(state.copyWith(status: ChatStatus.sending));

    final newMessage = MessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      teamId: teamId,
      senderId: 'current_user', // TODO: Replace with actual user ID
      senderName: 'You', // TODO: Replace with actual user name
      content: content.trim(),
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...state.messages, newMessage];

    emit(state.copyWith(status: ChatStatus.loaded, messages: updatedMessages));

    // TODO: Implement WebSocket/API call to send message
  }

  void connectToChat(String teamId) {
    emit(state.copyWith(isConnected: true));
    loadMessages(teamId);
  }

  void disconnectFromChat() {
    emit(state.copyWith(isConnected: false));
  }
}
