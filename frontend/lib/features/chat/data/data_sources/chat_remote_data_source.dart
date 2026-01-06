import 'dart:async';
import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/chat/data/models/message_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

abstract class ChatRemoteDataSource {
  Stream<MessageModel> get messageStream;
  Stream<void> get onConnected;
  Stream<Map<String, dynamic>> get userStatusStream;
  Future<void> connect(String teamId, String token);
  Future<void> disconnect();
  Future<void> sendMessage(String teamId, String content, {String? replyToId});
  Future<List<MessageModel>> getTeamMessages(String teamId, {String? token});
  bool get isConnected;
  String? get currentTeamId;
  void emit(String event, dynamic data);
  Future<void> deleteMessages(String teamId, List<String> messageIds);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  io.Socket? _socket;
  final StreamController<MessageModel> _messageStreamController =
      StreamController<MessageModel>.broadcast();
  final StreamController<void> _connectedStreamController =
      StreamController<void>.broadcast();
  final StreamController<Map<String, dynamic>> _userStatusStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  final String _baseUrl;
  String? _currentTeamId;
  String? _currentToken;
  Completer<void>? _connectionCompleter;
  Timer? _reconnectTimer;
  bool _isDisposed = false;

  // Track processed message IDs to prevent duplicates
  final Set<String> _processedMessageIds = {};
  Timer? _messageCleanupTimer;

  ChatRemoteDataSourceImpl()
    : _baseUrl =
          dotenv.env['API_URL']?.replaceFirst('/api/v1', '') ??
          'https://fattiest-ebony-supplely.ngrok-free.dev' {
    // Cleanup old message IDs every 5 minutes
    _messageCleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_processedMessageIds.length > 1000) {
        _processedMessageIds.clear();
      }
    });
  }

  Future<String?> _getAuthToken() async {
    try {
      final authRepository = GetIt.I<AuthRepository>();
      return await authRepository.getAccessToken();
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  void _setupSocketListeners() {
    if (_socket == null || _isDisposed) return;

    // Remove all existing listeners first to prevent duplicates
    _socket!.off('connect');
    _socket!.off('disconnect');
    _socket!.off('new_message');
    _socket!.off('error');
    _socket!.off('connection_success');
    _socket!.off('joined_team');
    _socket!.off('connect_error');
    _socket!.off('authentication_error');
    _socket!.off('message_sent');
    _socket!.off('userStatus');
    _socket!.off('messages_deleted');

    _socket!.onConnect((_) {
      if (_isDisposed) return;
      print(
        '✅ SOCKET CONNECTED - ID: ${_socket!.id} for team: $_currentTeamId',
      );
      _connectedStreamController.add(null);

      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter!.complete();
        _connectionCompleter = null;
      }

      _reconnectTimer?.cancel();
      _reconnectTimer = null;
    });

    _socket!.onDisconnect((reason) {
      if (_isDisposed) return;
      print('🔴 SOCKET DISCONNECTED: $reason for team: $_currentTeamId');

      if (_currentTeamId != null &&
          _currentToken != null &&
          reason != 'io client disconnect') {
        print('🔄 Scheduling reconnect in 3 seconds...');
        _reconnectTimer?.cancel();
        _reconnectTimer = Timer(const Duration(seconds: 3), () {
          if (!_isDisposed && _currentTeamId != null && _currentToken != null) {
            print('🔄 Auto-reconnecting to team: $_currentTeamId');
            connect(_currentTeamId!, _currentToken!);
          }
        });
      }

      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter!.completeError(
          Exception('Socket disconnected: $reason'),
        );
        _connectionCompleter = null;
      }
    });

    _socket!.on('new_message', (data) {
      if (_isDisposed) return;

      try {
        print('📨 Received new message for team $_currentTeamId: $data');
        final message = MessageModel.fromJson(data);

        // CRITICAL: Only process messages for current team
        if (message.teamId != _currentTeamId) {
          print('⚠️ Ignoring message from different team: ${message.teamId}');
          return;
        }

        // Prevent duplicate messages
        final messageId = message.id;
        if (_processedMessageIds.contains(messageId)) {
          print('⚠️ Duplicate message detected, skipping: $messageId');
          return;
        }

        _processedMessageIds.add(messageId);
        _messageStreamController.add(message);
      } catch (e) {
        print('❌ PARSE ERROR: $e');
      }
    });

    // Listen for user status updates
    _socket!.on('userStatus', (data) {
      if (_isDisposed) return;

      try {
        print('👤 User status update: $data');
        final statusData = Map<String, dynamic>.from(data);
        _userStatusStreamController.add(statusData);
      } catch (e) {
        print('❌ User status parse error: $e');
      }
    });

    // Listen for messages deleted event
    _socket!.on('messages_deleted', (data) {
      if (_isDisposed) return;

      try {
        print('🗑️ Received messages_deleted event: $data');
        _userStatusStreamController.add({
          'type': 'messages_deleted',
          'messageIds': data['messageIds'],
          'deletedBy': data['deletedBy'],
          'teamId': data['teamId'],
        });
      } catch (e) {
        print('❌ Messages deleted parse error: $e');
      }
    });

    _socket!.on('error', (err) {
      if (_isDisposed) return;
      print('❌ SOCKET ERROR: $err');
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter!.completeError(Exception('Socket error: $err'));
        _connectionCompleter = null;
      }
    });

    _socket!.on('connection_success', (data) {
      if (_isDisposed) return;
      print('🎉 CONNECTION SUCCESS for team $_currentTeamId: $data');
    });

    _socket!.on('joined_team', (data) {
      if (_isDisposed) return;
      print('✅ JOINED TEAM: $data');
    });

    _socket!.on('connect_error', (error) {
      if (_isDisposed) return;
      print('❌ CONNECT ERROR: $error');
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter!.completeError(
          Exception('Connection failed: $error'),
        );
        _connectionCompleter = null;
      }
    });

    _socket!.on('authentication_error', (data) {
      if (_isDisposed) return;
      print('🔐 AUTH ERROR: $data');
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter!.completeError(
          Exception('Authentication failed: $data'),
        );
        _connectionCompleter = null;
      }
    });

    _socket!.on('message_sent', (data) {
      if (_isDisposed) return;
      print('✅ MESSAGE SENT CONFIRMATION: $data');
    });
  }

  @override
  Stream<MessageModel> get messageStream => _messageStreamController.stream;

  @override
  Stream<void> get onConnected => _connectedStreamController.stream;

  @override
  Stream<Map<String, dynamic>> get userStatusStream =>
      _userStatusStreamController.stream;

  @override
  bool get isConnected => _socket?.connected ?? false;

  @override
  String? get currentTeamId => _currentTeamId;

  @override
  void emit(String event, dynamic data) {
    if (_isDisposed || _socket == null || !_socket!.connected) {
      print('❌ Cannot emit $event - socket not connected');
      return;
    }

    print('📤 Emitting $event: $data');
    _socket!.emit(event, data);
  }

  @override
  Future<void> connect(String teamId, String token) async {
    if (_isDisposed) {
      throw Exception('DataSource has been disposed');
    }

    // If already connected to the same team, don't reconnect
    if (_socket != null && _socket!.connected && _currentTeamId == teamId) {
      print('✅ Already connected to team: $teamId');
      return;
    }

    // If connecting to a different team, disconnect first
    if (_currentTeamId != null && _currentTeamId != teamId) {
      print('🔄 Switching from team $_currentTeamId to $teamId');
      await disconnect();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _currentTeamId = teamId;
    _currentToken = token;

    print('🔄 Connecting to socket for team: $teamId');

    // Cleanup existing socket
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _connectionCompleter = Completer<void>();

    try {
      _socket = io.io(
        _baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(2000)
            .setAuth({'token': token})
            .setQuery({'teamId': teamId, 'token': token})
            .setExtraHeaders({'authorization': 'Bearer $token'})
            .setTimeout(30000)
            .build(),
      );

      _setupSocketListeners();

      final timer = Timer(const Duration(seconds: 15), () {
        if (_connectionCompleter != null &&
            !_connectionCompleter!.isCompleted) {
          print('⏰ Connection timeout after 15 seconds');
          _connectionCompleter!.completeError(
            TimeoutException('Connection timeout after 15 seconds'),
          );
          _connectionCompleter = null;
        }
      });

      print('🔌 Connecting socket...');
      _socket!.connect();

      await _connectionCompleter!.future;
      timer.cancel();

      print('✅ Socket connected successfully');

      // Join team
      _socket!.emit('join_team', {'teamId': teamId});
      print('🚀 Sent join_team request for team: $teamId');

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('❌ CONNECTION ERROR: $e');
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      _connectionCompleter = null;
      _currentTeamId = null;
      _currentToken = null;
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    if (_isDisposed) return;

    print('🔌 Disconnecting socket from team: $_currentTeamId');
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }

    _currentTeamId = null;
    _currentToken = null;
    _connectionCompleter = null;
    _processedMessageIds.clear();
  }

  @override
  Future<void> sendMessage(
    String teamId,
    String content, {
    String? replyToId,
  }) async {
    if (_isDisposed) {
      throw Exception('DataSource has been disposed');
    }

    if (_socket == null || !_socket!.connected) {
      throw Exception('Socket not connected');
    }

    if (_currentTeamId != teamId) {
      throw Exception(
        'Connected to wrong team. Expected: $teamId, Current: $_currentTeamId',
      );
    }

    print(
      '💬 Sending message to team $teamId: "$content"${replyToId != null ? ' (reply to: $replyToId)' : ''}',
    );

    final completer = Completer<void>();

    // Prepare message data with optional replyToId
    final messageData = {
      'teamId': teamId,
      'content': content,
      if (replyToId != null) 'replyToId': replyToId,
    };

    // Use emitWithAck for reliable delivery
    _socket!.emitWithAck(
      'send_message',
      messageData,
      ack: (response) {
        if (completer.isCompleted) return;

        print('✅ Received ACK: $response');
        if (response is Map && response['error'] != null) {
          completer.completeError(ServerFailure(response['error']));
        } else {
          completer.complete();
        }
      },
    );

    // Set a reasonable timeout
    final timer = Timer(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        print('⏰ Send message timeout');
        completer.completeError(TimeoutException('Send timeout'));
      }
    });

    try {
      await completer.future;
      timer.cancel();
      print('✅ Message sent successfully');
    } catch (e) {
      timer.cancel();
      print('❌ Error sending message: $e');
      rethrow;
    }
  }

  @override
  Future<List<MessageModel>> getTeamMessages(
    String teamId, {
    String? token,
  }) async {
    final authToken = token ?? await _getAuthToken();

    if (authToken == null) {
      throw const ServerFailure('No authentication token found');
    }

    // FIX: Correct the URL to match the backend route
    // Backend route: /api/v1/chat/teams/:teamId/messages
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/chat/teams/$teamId/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      return []; // No messages found
    } else {
      throw ServerFailure('Failed to load messages: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteMessages(String teamId, List<String> messageIds) async {
    if (_isDisposed) {
      throw Exception('DataSource has been disposed');
    }

    if (_socket == null || !_socket!.connected) {
      throw Exception('Socket not connected');
    }

    if (_currentTeamId != teamId) {
      throw Exception(
        'Connected to wrong team. Expected: $teamId, Current: $_currentTeamId',
      );
    }

    print('🗑️ Deleting ${messageIds.length} messages in team $teamId');
    print('🗑️ Message IDs: ${messageIds.join(", ")}');

    final completer = Completer<void>();
    bool ackReceived = false;

    // Set timeout BEFORE emitting
    final timer = Timer(const Duration(seconds: 15), () {
      if (!completer.isCompleted && !ackReceived) {
        print('⏰ Delete messages timeout');
        completer.completeError(
          TimeoutException('Delete timeout after 15 seconds'),
        );
      }
    });

    try {
      // Use emitWithAck for reliable delivery
      print('📤 Emitting delete_messages event...');

      _socket!.emitWithAck(
        'delete_messages',
        {'teamId': teamId, 'messageIds': messageIds},
        ack: (response) {
          ackReceived = true;

          if (completer.isCompleted) {
            print('⚠️ Acknowledgment received after timeout');
            return;
          }

          print('✅ Received delete ACK: $response');

          // Handle different response types
          if (response == null) {
            print('⚠️ Null response from server');
            completer.completeError(ServerFailure('No response from server'));
            return;
          }

          // Response should be a Map
          if (response is Map) {
            if (response['success'] == true) {
              print('✅ Delete acknowledged successfully');
              completer.complete();
            } else if (response['error'] != null) {
              print('❌ Server error: ${response['error']}');
              completer.completeError(ServerFailure(response['error']));
            } else {
              print('⚠️ Unexpected response format: $response');
              completer.completeError(
                ServerFailure('Unexpected response: $response'),
              );
            }
          } else {
            print(
              '⚠️ Response is not a Map: $response (${response.runtimeType})',
            );
            completer.completeError(
              ServerFailure('Invalid response type: ${response.runtimeType}'),
            );
          }
        },
      );

      print('⏳ Waiting for acknowledgment...');
      await completer.future;
      timer.cancel();
      print('✅ Messages deleted successfully');
    } catch (e) {
      timer.cancel();
      print('❌ Error deleting messages: $e');
      rethrow;
    }
  }

  void dispose() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _messageCleanupTimer?.cancel();
    _messageStreamController.close();
    _connectedStreamController.close();
    _userStatusStreamController.close();
    _socket?.dispose();
    _processedMessageIds.clear();
  }
}
