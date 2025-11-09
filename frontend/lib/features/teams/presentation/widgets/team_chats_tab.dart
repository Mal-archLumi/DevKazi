import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/chat/presentation/cubits/chat_cubit.dart';
import 'package:frontend/features/chat/presentation/cubits/chat_state.dart';
import 'package:frontend/core/injection_container.dart' as di;

class TeamChatsTab extends StatefulWidget {
  final String teamId;
  final String accessToken;

  const TeamChatsTab({
    super.key,
    required this.teamId,
    required this.accessToken,
  });

  @override
  State<TeamChatsTab> createState() => _TeamChatsTabState();
}

class _TeamChatsTabState extends State<TeamChatsTab> {
  UserEntity? _currentUser;
  bool _isLoading = true;
  final TextEditingController _messageController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
    _initializeChat();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _messageController.text.trim().isNotEmpty;
    });
  }

  Future<void> _initializeChat() async {
    try {
      final authRepository = di.getIt<AuthRepository>();
      final userResult = await authRepository.getCurrentUser();

      userResult.fold(
        (failure) {
          print('❌ Failed to get current user: $failure');
          setState(() {
            _isLoading = false;
          });
        },
        (user) {
          setState(() {
            _currentUser = user;
            _isLoading = false;
          });

          final chatCubit = context.read<ChatCubit>();
          chatCubit.connectToChat(widget.teamId, widget.accessToken, user);
        },
      );
    } catch (e) {
      print('❌ Error initializing chat: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      context.read<ChatCubit>().sendMessage(widget.teamId, content);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load user data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your authentication',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeChat,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state.status == ChatStatus.error && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == ChatStatus.connecting ||
            state.status == ChatStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Connection status indicator
            if (state.isConnected != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: state.isConnected!
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      state.isConnected! ? Icons.circle : Icons.circle_outlined,
                      size: 8,
                      color: state.isConnected! ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state.isConnected! ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        fontSize: 12,
                        color: state.isConnected! ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

            // Chat messages
            Expanded(
              child: state.messages.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Start a conversation!',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      // REMOVED: reverse: true - This was causing messages to be inverted
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        final isCurrentUser =
                            message.senderId == _currentUser!.id;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: isCurrentUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              if (!isCurrentUser)
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    message.senderName.isNotEmpty
                                        ? message.senderName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              if (!isCurrentUser) const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isCurrentUser
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (!isCurrentUser)
                                        Text(
                                          message.senderName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      if (!isCurrentUser)
                                        const SizedBox(height: 4),
                                      Text(
                                        message.content,
                                        style: TextStyle(
                                          color: isCurrentUser
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.onPrimary
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color:
                                              (isCurrentUser
                                                      ? Theme.of(
                                                          context,
                                                        ).colorScheme.onPrimary
                                                      : Theme.of(
                                                          context,
                                                        ).colorScheme.onSurface)
                                                  .withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isCurrentUser) const SizedBox(width: 8),
                              if (isCurrentUser)
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.green,
                                  child: Text(
                                    'You',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Message input field
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (value) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _hasText
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey, // Changes color based on text input
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: _hasText ? Colors.white : Colors.white70,
                      ),
                      onPressed: _hasText ? _sendMessage : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();

    // Only disconnect if we're actually leaving the team details page
    // Don't dispose the cubit here as it's managed by Provider
    super.dispose();
  }
}
