import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/chat/domain/entities/message_entity.dart';
import 'package:frontend/features/chat/presentation/cubits/chat_cubit.dart';
import 'package:frontend/features/chat/presentation/cubits/chat_state.dart';
import 'package:frontend/core/injection_container.dart' as di;
import 'package:frontend/features/chat/presentation/widgets/message_bubble.dart';
import 'package:frontend/features/user/presentation/cubits/user_cubit.dart';

class TeamChatsTab extends StatefulWidget {
  final String teamId;
  final String accessToken;
  final UserEntity currentUser;

  const TeamChatsTab({
    super.key,
    required this.teamId,
    required this.accessToken,
    required this.currentUser,
  });

  @override
  State<TeamChatsTab> createState() => _TeamChatsTabState();
}

class _TeamChatsTabState extends State<TeamChatsTab> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasText = false;
  late ChatCubit _chatCubit;

  // Track if we've scrolled to bottom
  bool _isAtBottom = true;

  // Track last team to prevent duplicate connections
  String? _lastConnectedTeamId;

  // Track if we should scroll to bottom on initial load
  bool _isInitialLoad = true;

  // Track connection retry attempts
  int _connectionRetryCount = 0;
  static const int _maxRetries = 3;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
    _chatCubit = di.getIt<ChatCubit>();

    // Listen to scroll position
    _scrollController.addListener(_scrollListener);

    // Initialize chat connection
    _initializeChat();
  }

  void _initializeChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectToChat();
    });
  }

  Future<void> _connectToChat({bool isRetry = false}) async {
    if (isRetry) {
      _connectionRetryCount++;
      if (_connectionRetryCount > _maxRetries) {
        debugPrint('🔄 Max retry attempts reached for team ${widget.teamId}');
        return;
      }

      debugPrint(
        '🔄 Retry attempt $_connectionRetryCount for team ${widget.teamId}',
      );
      await Future.delayed(Duration(seconds: _connectionRetryCount * 2));
    } else {
      _connectionRetryCount = 0;
    }

    if (_lastConnectedTeamId != widget.teamId) {
      debugPrint('🔄 TeamChatsTab: Connecting to team ${widget.teamId}');
      _chatCubit.connectToChat(
        widget.teamId,
        widget.accessToken,
        widget.currentUser,
      );
      _lastConnectedTeamId = widget.teamId;

      // Mark as initial load to scroll to bottom when messages arrive
      _isInitialLoad = true;
    }
  }

  @override
  void didUpdateWidget(TeamChatsTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle team switch
    if (oldWidget.teamId != widget.teamId) {
      debugPrint(
        '🔄 TeamChatsTab: Team changed from ${oldWidget.teamId} to ${widget.teamId}',
      );

      // Cancel any pending retry timer
      _retryTimer?.cancel();
      _retryTimer = null;

      // Clear text input
      _messageController.clear();

      // Reset retry counter
      _connectionRetryCount = 0;

      // Connect to new team
      _connectToChat();
    }
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    // Check if we're at the bottom
    final threshold = 100.0;
    final position = _scrollController.position;
    _isAtBottom = position.pixels >= position.maxScrollExtent - threshold;
  }

  void _onTextChanged() {
    if (!mounted) return;
    setState(() {
      _hasText = _messageController.text.trim().isNotEmpty;
    });
  }

  Future<void> _onRefresh() async {
    debugPrint('🔄 Refreshing chat for team ${widget.teamId}');
    _chatCubit.loadMessages(widget.teamId);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _onManualReconnect() async {
    debugPrint('🔄 Manual reconnect requested for team ${widget.teamId}');

    // Show loading state
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reconnecting...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );

    // Reset retry counter
    _connectionRetryCount = 0;

    // Reconnect
    await _connectToChat();
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        if (animate) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
        _isAtBottom = true;
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
    if (_chatCubit.state.isSelectionMode) {
      _chatCubit.toggleMessageSelection(messageId);
    }
  }

  void _handleMessageLongPress(String messageId) {
    _chatCubit.toggleMessageSelection(messageId);
    _showMessageContextMenu(messageId);
  }

  void _showMessageContextMenu(String messageId) {
    final message = _chatCubit.state.messages.firstWhere(
      (msg) => msg.id == messageId,
      orElse: () => throw Exception('Message not found'),
    );

    final isOwnMessage = message.senderId == widget.currentUser.id;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _chatCubit.setReplyingTo(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Text'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _copyToClipboard(message.content);
                _chatCubit.clearSelection();
              },
            ),
            if (isOwnMessage)
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _chatCubit.toggleMessageSelection(messageId);
                  _showDeleteConfirmation([messageId]);
                },
              ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _chatCubit.clearSelection();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(List<String> messageIds) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Message'),
        content: Text(
          messageIds.length == 1
              ? 'Are you sure you want to delete this message?'
              : 'Are you sure you want to delete ${messageIds.length} messages?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _chatCubit.deleteSelectedMessages(widget.teamId);
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

  Widget _buildActionAppBar(ChatState state) {
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
                _chatCubit.setReplyingTo(message);
                _chatCubit.clearSelection();
              },
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () =>
                _showDeleteConfirmation(state.selectedMessageIds.toList()),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _chatCubit.clearSelection,
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview(ChatState state) {
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
          GestureDetector(
            onTap: () {
              debugPrint('🔴 Cancel reply tapped');
              _chatCubit.setReplyingTo(null);
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.close,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Pull down to refresh',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatState state) {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.messages.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final isCurrentUser = message.senderId == widget.currentUser.id;

        MessageEntity? replyToMessage;
        if (message.replyToId != null) {
          replyToMessage = state.messages.cast<MessageEntity?>().firstWhere(
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
          onLongPress: () => _handleMessageLongPress(message.id),
        );
      },
    );
  }

  Widget _buildConnectionStatus(ChatState state) {
    final isConnected = state.isConnected;
    final isConnecting = state.status == ChatStatus.connecting;
    final hasAuthError =
        state.errorMessage?.toLowerCase().contains('jwt') == true ||
        state.errorMessage?.toLowerCase().contains('token') == true ||
        state.errorMessage?.toLowerCase().contains('auth') == true ||
        state.errorMessage?.toLowerCase().contains('expired') == true;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isConnecting) {
      statusColor = Colors.orange;
      statusText = 'Connecting...';
      statusIcon = Icons.circle_outlined;
    } else if (isConnected) {
      statusColor = Colors.green;
      statusText = 'Connected';
      statusIcon = Icons.circle;
    } else {
      statusColor = Colors.red;
      statusText = 'Disconnected';
      statusIcon = Icons.circle_outlined;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: statusColor.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isConnecting)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: statusColor,
              ),
            )
          else
            Icon(statusIcon, size: 8, color: statusColor),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
          if (!isConnected && !isConnecting) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _onManualReconnect,
              child: Row(
                children: [
                  Text(
                    '• Tap to reconnect',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_connectionRetryCount > 0)
                    Text(
                      ' ($_connectionRetryCount/$_maxRetries)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (hasAuthError) ...[
            const SizedBox(width: 8),
            Text(
              '• Session expired',
              style: TextStyle(
                fontSize: 11,
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatCubit,
      child: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state.status == ChatStatus.error && mounted) {
            // Check if it's an auth error
            final isAuthError =
                state.errorMessage?.toLowerCase().contains('jwt') == true ||
                state.errorMessage?.toLowerCase().contains('token') == true ||
                state.errorMessage?.toLowerCase().contains('auth') == true ||
                state.errorMessage?.toLowerCase().contains('expired') == true;

            if (isAuthError) {
              // Auto-retry on auth errors after a delay
              _retryTimer?.cancel();
              _retryTimer = Timer(const Duration(seconds: 3), () {
                if (mounted && !state.isConnected) {
                  _connectToChat(isRetry: true);
                }
              });
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: isAuthError ? Colors.orange : Colors.red,
                duration: const Duration(seconds: 3),
                action: isAuthError
                    ? SnackBarAction(
                        label: 'Retry',
                        textColor: Colors.white,
                        onPressed: _onManualReconnect,
                      )
                    : null,
              ),
            );
          }

          // Handle connection state changes
          if (state.status == ChatStatus.connected &&
              !state.isConnected &&
              mounted) {
            // Auto-retry on unexpected disconnection
            _retryTimer?.cancel();
            _retryTimer = Timer(const Duration(seconds: 5), () {
              if (mounted && !state.isConnected) {
                _connectToChat(isRetry: true);
              }
            });
          }

          // ✅ KEY FIX: Scroll to bottom when messages are first loaded
          if (_isInitialLoad &&
              state.status == ChatStatus.loaded &&
              state.messages.isNotEmpty) {
            _isInitialLoad = false;
            // Use a longer delay to ensure ListView is fully built
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                _scrollToBottom(animate: false);
              }
            });
          }

          // Also scroll when user is at bottom and new message arrives
          if (_isAtBottom &&
              state.status == ChatStatus.loaded &&
              state.messages.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted && _isAtBottom) {
                _scrollToBottom(animate: true);
              }
            });
          }
        },
        builder: (context, state) {
          if (state.status == ChatStatus.connecting ||
              (state.status == ChatStatus.loading && state.messages.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildActionAppBar(state),

              // Connection status with improved UI
              _buildConnectionStatus(state),

              // Messages
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: Theme.of(context).colorScheme.primary,
                  child: state.messages.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: _buildEmptyState(),
                          ),
                        )
                      : _buildMessageList(state),
                ),
              ),

              // Input
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
                    _buildReplyPreview(state),
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
                              onSubmitted: (value) => _sendMessage(_chatCubit),
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
                                  ? () => _sendMessage(_chatCubit)
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
    _retryTimer?.cancel();
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
}
