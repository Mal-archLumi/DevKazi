import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for Clipboard
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/chat/domain/entities/message_entity.dart';
import 'package:frontend/features/chat/presentation/cubits/chat_cubit.dart';
import 'package:frontend/features/chat/presentation/cubits/chat_state.dart';
import 'package:frontend/core/injection_container.dart' as di;
import 'package:frontend/features/chat/presentation/widgets/message_bubble.dart';
// Assuming MessageBubble is defined elsewhere or add it here if needed
// import 'path/to/message_bubble.dart'; // Add if MessageBubble is in a separate file

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
  final ScrollController _scrollController = ScrollController();
  bool _hasText = false;
  late ChatCubit _chatCubit;
  String? _previousTeamId;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
    _chatCubit = di.getIt<ChatCubit>();
    _initializeChat();
  }

  @override
  void didUpdateWidget(TeamChatsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle team switch
    if (oldWidget.teamId != widget.teamId) {
      _handleTeamSwitch(oldWidget.teamId);
    }
  }

  void _handleTeamSwitch(String oldTeamId) {
    print('🔄 Switching from team $oldTeamId to ${widget.teamId}');
    _previousTeamId = oldTeamId;

    // Clear messages immediately to prevent glitch
    _chatCubit.clearMessages();

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    // Disconnect from old team and connect to new one
    _chatCubit.disconnectFromChat().then((_) {
      if (mounted) {
        _initializeChat();
      }
    });
  }

  void _onTextChanged() {
    if (!mounted) return;
    setState(() {
      _hasText = _messageController.text.trim().isNotEmpty;
    });
  }

  Future<void> _initializeChat() async {
    try {
      final authRepository = di.getIt<AuthRepository>();
      final userResult = await authRepository.getCurrentUser();

      if (!mounted) return;

      userResult.fold(
        (failure) {
          print('❌ Failed to get current user: $failure');
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
        },
        (user) {
          if (!mounted) return;
          setState(() {
            _currentUser = user;
            _isLoading = false;
          });

          _chatCubit.connectToChat(widget.teamId, widget.accessToken, user);
        },
      );
    } catch (e) {
      print('❌ Error initializing chat: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animate) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  void _sendMessage(ChatCubit cubit) {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      cubit.sendMessage(
        widget.teamId,
        content,
        replyToId: cubit.state.replyingTo?.id,
      );
      _messageController.clear();

      // Scroll to bottom after sending
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom(animate: true);
      });
    }
  }

  void _handleMessageTap(String messageId) {
    final cubit = BlocProvider.of<ChatCubit>(context);

    if (cubit.state.isSelectionMode) {
      cubit.toggleMessageSelection(messageId);
    }
  }

  void _handleMessageLongPress(String messageId) {
    final cubit = BlocProvider.of<ChatCubit>(context);
    cubit.toggleMessageSelection(messageId);

    // Show context menu
    _showMessageContextMenu(messageId);
  }

  void _showMessageContextMenu(String messageId) {
    final cubit = BlocProvider.of<ChatCubit>(context);
    final message = cubit.state.messages.firstWhere(
      (msg) => msg.id == messageId,
      orElse: () => throw Exception('Message not found'),
    );

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                cubit.setReplyingTo(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation([messageId]);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Text'),
              onTap: () {
                Navigator.pop(context);
                _copyToClipboard(message.content);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(List<String> messageIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: Text(
          messageIds.length == 1
              ? 'Are you sure you want to delete this message?'
              : 'Are you sure you want to delete ${messageIds.length} messages?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final cubit = BlocProvider.of<ChatCubit>(context);
              cubit.deleteSelectedMessages(widget.teamId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  Widget _buildActionAppBar(ChatState state, ChatCubit cubit) {
    if (!state.isSelectionMode) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          Text(
            '${state.selectedMessageIds.length} selected',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const Spacer(),
          if (state.selectedMessageIds.length == 1)
            IconButton(
              icon: const Icon(Icons.reply),
              onPressed: () {
                final messageId = state.selectedMessageIds.first;
                final message = state.messages.firstWhere(
                  (msg) => msg.id == messageId,
                );
                cubit.setReplyingTo(message);
                cubit.clearSelection();
              },
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () =>
                _showDeleteConfirmation(state.selectedMessageIds.toList()),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: cubit.clearSelection,
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview(ChatState state, ChatCubit cubit) {
    if (state.replyingTo == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.reply,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${state.replyingTo!.senderName}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  state.replyingTo!.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            iconSize: 20,
            onPressed: () => cubit.setReplyingTo(null),
          ),
        ],
      ),
    );
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

    return BlocProvider.value(
      value: _chatCubit,
      child: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state.status == ChatStatus.error && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }

          // Auto-scroll when messages are loaded or received
          if (state.status == ChatStatus.loaded && state.messages.isNotEmpty) {
            _scrollToBottom(animate: false);
          }
        },
        builder: (context, state) {
          final cubit = BlocProvider.of<ChatCubit>(context);
          final isConnected = state.isConnected;

          if (state.status == ChatStatus.connecting ||
              (state.status == ChatStatus.loading && state.messages.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Action App Bar for selection mode
              _buildActionAppBar(state, cubit),

              // Connection status indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: isConnected
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isConnected ? Icons.circle : Icons.circle_outlined,
                      size: 8,
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isConnected ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        fontSize: 12,
                        color: isConnected ? Colors.green : Colors.red,
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
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: state.messages.length,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                          final isCurrentUser =
                              message.senderId == _currentUser!.id;

                          // Find reply message if this is a reply
                          MessageEntity? replyToMessage;
                          if (message.replyToId != null) {
                            replyToMessage = state.messages
                                .cast<MessageEntity?>()
                                .firstWhere(
                                  (msg) => msg?.id == message.replyToId,
                                  orElse: () => null,
                                );
                          }

                          return MessageBubble(
                            message: message,
                            isCurrentUser: isCurrentUser,
                            context: context,
                            isSelected: state.isMessageSelected(message.id),
                            isSelectionMode: state.isSelectionMode,
                            replyToMessage: replyToMessage,
                            onTap: () => _handleMessageTap(message.id),
                            onLongPress: () =>
                                _handleMessageLongPress(message.id),
                          );
                        },
                      ),
              ),

              // Message input field (updated to handle replies)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Reply preview in input area
                    _buildReplyPreview(state, cubit),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: state.replyingTo != null
                                    ? 'Reply to ${state.replyingTo!.senderName}...'
                                    : 'Type a message...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                              onSubmitted: (value) => _sendMessage(cubit),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _hasText
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.send),
                              color: _hasText ? Colors.white : Colors.white70,
                              onPressed: _hasText
                                  ? () => _sendMessage(cubit)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// Note: MessageBubble widget needs to be defined. Assuming it's implemented separately.
// If not, you can replace the MessageBubble usage with the original inline Container code, but updated for selection and reply display.
