import 'dart:async';
import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/core/errors/exceptions.dart';
import 'package:frontend/core/network/network_info.dart';
import 'package:frontend/features/chat/data/models/message_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

abstract class ChatRemoteDataSource {
  Stream<MessageModel> get messageStream;
  Stream<void> get onConnected;
  Future<void> connect(String teamId, String token);
  Future<void> disconnect();
  Future<void> sendMessage(String teamId, String content);
  Future<List<MessageModel>> getTeamMessages(String teamId);
  bool get isConnected;
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  io.Socket? _socket;
  final NetworkInfo _networkInfo;
  final StreamController<MessageModel> _messageStreamController =
      StreamController<MessageModel>.broadcast();
  final StreamController<void> _connectedStreamController =
      StreamController<void>.broadcast();

  final String _baseUrl;
  String? _currentTeamId;
  String? _currentToken;
  Completer<void>? _connectionCompleter;
  Timer? _reconnectTimer;

  ChatRemoteDataSourceImpl({required NetworkInfo networkInfo})
    : _networkInfo = networkInfo,
      _baseUrl =
          dotenv.env['API_URL']?.replaceFirst('/api/v1', '') ??
          'https://fattiest-ebony-supplely.ngrok-free.dev';

  void _setupSocketListeners() {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      print('✅ SOCKET CONNECTED - ID: ${_socket!.id}');
      _connectedStreamController.add(null);

      // Complete connection completer
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter!.complete();
        _connectionCompleter = null;
      }

      // Cancel any reconnect timer
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
    });

    _socket!.onDisconnect((reason) {
      print('🔴 SOCKET DISCONNECTED: $reason');

      // Attempt to reconnect if we have credentials
      if (_currentTeamId != null && _currentToken != null) {
        print('🔄 Scheduling reconnect in 3 seconds...');
        _reconnectTimer?.cancel();
        _reconnectTimer = Timer(Duration(seconds: 3), () {
          if (_currentTeamId != null && _currentToken != null) {
            print('🔄 Auto-reconnecting...');
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
      try {
        print('📨 Received new message: $data');
        final message = MessageModel.fromJson(data);
        _messageStreamController.add(message);
      } catch (e) {
        print('❌ PARSE ERROR: $e');
      }
    });

    _socket!.on('error', (err) {
      print('❌ SOCKET ERROR: $err');
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter!.completeError(Exception('Socket error: $err'));
        _connectionCompleter = null;
      }
    });

    _socket!.on('connection_success', (data) {
      print('🎉 CONNECTION SUCCESS: $data');
    });

    _socket!.on('joined_team', (data) {
      print('✅ JOINED TEAM: $data');
    });

    _socket!.on('connect_error', (error) {
      print('❌ CONNECT ERROR: $error');
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter!.completeError(
          Exception('Connection failed: $error'),
        );
        _connectionCompleter = null;
      }
    });

    _socket!.on('authentication_error', (data) {
      print('🔐 AUTH ERROR: $data');
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter!.completeError(
          Exception('Authentication failed: $data'),
        );
        _connectionCompleter = null;
      }
    });

    _socket!.on('message_sent', (data) {
      print('✅ MESSAGE SENT CONFIRMATION: $data');
    });
  }

  @override
  Stream<MessageModel> get messageStream => _messageStreamController.stream;

  @override
  Stream<void> get onConnected => _connectedStreamController.stream;

  @override
  bool get isConnected => _socket?.connected ?? false;

  @override
  Future<void> connect(String teamId, String token) async {
    _currentTeamId = teamId;
    _currentToken = token;

    print('🔄 Connecting to socket for team: $teamId');
    print('🔑 Token: ${token.substring(0, 20)}...');

    // Cleanup existing socket
    if (_socket != null && _socket!.connected) {
      print('🔄 Socket already connected, reconnecting...');
      _socket!.disconnect();
      await Future.delayed(Duration(milliseconds: 500));
    }

    _connectionCompleter = Completer<void>();

    try {
      // Configure socket with auth in multiple locations for maximum compatibility
      _socket = io.io(
        _baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .enableReconnection() // Enable auto-reconnection
            .setReconnectionAttempts(5)
            .setReconnectionDelay(2000)
            .setAuth({
              'token': token, // PRIMARY: Standard Socket.IO auth
            })
            .setQuery({
              'teamId': teamId,
              'token': token, // FALLBACK: Query parameter
            })
            .setExtraHeaders({
              'authorization': 'Bearer $token', // FALLBACK: HTTP header style
            })
            .setTimeout(30000)
            .build(),
      );

      print('🔧 Socket configured with multi-location auth and auto-reconnect');

      // Setup listeners
      _setupSocketListeners();

      // Set connection timeout
      final timer = Timer(Duration(seconds: 15), () {
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

      // Wait for connection
      await _connectionCompleter!.future;
      timer.cancel();

      print('✅ Socket connected successfully');
      print('✅ Socket connection state: ${_socket!.connected}');

      // Join team after connection
      _socket!.emit('join_team', {'teamId': teamId});
      print('🚀 Sent join_team request for team: $teamId');

      // Wait a bit for join_team to complete
      await Future.delayed(Duration(milliseconds: 500));

      print('✅ Final connection state: ${_socket!.connected}');
    } catch (e) {
      print('❌ CONNECTION ERROR: $e');
      _socket?.disconnect();
      _socket = null;
      _connectionCompleter = null;
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    print('🔌 Disconnecting socket...');
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentTeamId = null;
    _currentToken = null;
    _connectionCompleter = null;
  }

  @override
  Future<void> sendMessage(String teamId, String content) async {
    print('💬 Attempting to send message...');
    print('🔍 Socket null? ${_socket == null}');
    print('🔍 Socket connected? ${_socket?.connected}');

    if (_socket == null) {
      print('❌ Socket is null!');
      throw Exception('Socket not initialized');
    }

    if (!_socket!.connected) {
      print('❌ Socket not connected! Attempting reconnect...');

      // Try to reconnect if we have credentials
      if (_currentTeamId != null && _currentToken != null) {
        await connect(_currentTeamId!, _currentToken!);

        // Wait a bit for connection to establish
        await Future.delayed(Duration(milliseconds: 1000));

        if (!_socket!.connected) {
          throw Exception('Socket not connected after reconnect attempt');
        }
      } else {
        throw Exception(
          'Socket not connected and no credentials for reconnect',
        );
      }
    }

    final completer = Completer<void>();
    final timer = Timer(Duration(seconds: 8), () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('Send timeout'));
      }
    });

    print('💬 Sending message to team $teamId: "$content"');
    print('🔍 Socket ID: ${_socket!.id}');

    try {
      _socket!.emitWithAck(
        'send_message',
        {'teamId': teamId, 'content': content},
        ack: (res) {
          timer.cancel();
          print('✅ Received ACK: $res');
          if (res is Map && res['error'] != null) {
            completer.completeError(ServerFailure(res['error']));
          } else {
            print('✅ Message sent successfully');
            completer.complete();
          }
        },
      );

      await completer.future.timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException(
            'Message send timeout - no acknowledgment received',
          );
        },
      );
    } catch (e) {
      timer.cancel();
      print('❌ Error in sendMessage: $e');
      rethrow;
    }
  }

  @override
  Future<List<MessageModel>> getTeamMessages(String teamId) async {
    try {
      final authRepository = GetIt.I<AuthRepository>();
      final token = await authRepository.getAccessToken();

      if (token == null) {
        throw ServerFailure('No authentication token found');
      }

      final baseUrl = '$_baseUrl/api/v1';
      print('📡 HTTP: Loading messages for team $teamId');

      final response = await http
          .get(
            Uri.parse('$baseUrl/chat/teams/$teamId/messages'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(Duration(seconds: 10));

      print('📡 HTTP: Response status ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('📡 HTTP: Loaded ${data.length} messages');
        return data.map((json) => MessageModel.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        print('📡 HTTP: No messages found (404)');
        return [];
      } else {
        throw ServerFailure(
          'Failed to load messages: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ HTTP GET MESSAGES ERROR: $e');
      rethrow;
    }
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _messageStreamController.close();
    _connectedStreamController.close();
    _socket?.dispose();
  }
}
