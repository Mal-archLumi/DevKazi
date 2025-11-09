// lib/features/chat/data/data_sources/chat_remote_data_source.dart
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

// Import AuthRepository
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

abstract class ChatRemoteDataSource {
  Stream<MessageModel> get messageStream;
  Stream<void> get onAuthenticated;
  Future<void> connect(String teamId, String token);
  Future<void> disconnect();
  Future<void> sendMessage(String teamId, String content);
  Future<List<MessageModel>> getTeamMessages(String teamId);
  bool get isConnected;
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  late io.Socket _socket;
  final NetworkInfo _networkInfo;
  final StreamController<MessageModel> _messageStreamController =
      StreamController<MessageModel>.broadcast();
  final StreamController<void> _authenticatedStreamController =
      StreamController<void>.broadcast();

  final String _baseUrl;
  bool _isConnected = false;
  String? _currentTeamId;
  String? _currentToken;

  ChatRemoteDataSourceImpl({required NetworkInfo networkInfo})
    : _networkInfo = networkInfo,
      _baseUrl =
          dotenv.env['API_URL']?.replaceFirst('/api/v1', '') ??
          'https://fattiest-ebony-supplely.ngrok-free.dev';

  void _setupSocketListeners() {
    _socket.on('connect', (_) {
      print('✅ SOCKET CONNECTED - ID: ${_socket.id}');
      _isConnected = true;

      // Send manual authentication as backup
      if (_currentToken != null) {
        print('🔐 Sending manual authentication as backup...');
        _socket.emit('authenticate', {'token': _currentToken});
      }
    });

    _socket.on('disconnect', (reason) {
      print('🔴 SOCKET DISCONNECTED: $reason');
      _isConnected = false;
    });

    _socket.on('new_message', (data) {
      try {
        print('📨 Received new message: $data');
        final message = MessageModel.fromJson(data);
        _messageStreamController.add(message);
      } catch (e) {
        print('❌ PARSE ERROR: $e');
      }
    });

    _socket.on('error', (err) => print('❌ SOCKET ERROR: $err'));

    _socket.on('authentication_error', (data) {
      print('🔐 AUTH FAILED: $data');
    });

    _socket.on('authenticated', (data) {
      print('🎉 AUTH SUCCESS! $data');
      _authenticatedStreamController.add(null);

      // Now that we're authenticated, join the team
      if (_currentTeamId != null) {
        print('🚀 Joining team after authentication: $_currentTeamId');
        _socket.emit('join_team', {'teamId': _currentTeamId});
      }
    });

    _socket.on('authentication_required', (data) {
      print('⚠️ AUTH REQUIRED: $data');
      // Try to authenticate again if we have a token
      if (_currentToken != null) {
        print('🔄 Retrying authentication...');
        _socket.emit('authenticate', {'token': _currentToken});
      }
    });

    _socket.on('connection_success', (data) {
      print('✅ CONNECTION SUCCESS: $data');
    });

    _socket.on('joined_team', (data) {
      print('✅ JOINED TEAM: $data');
    });

    _socket.on('user_joined', (data) {
      print('👤 USER JOINED: $data');
    });
  }

  @override
  Stream<MessageModel> get messageStream => _messageStreamController.stream;

  @override
  Stream<void> get onAuthenticated => _authenticatedStreamController.stream;

  @override
  bool get isConnected => _isConnected;

  @override
  Future<void> connect(String teamId, String token) async {
    _currentTeamId = teamId;
    _currentToken = token;

    print('🔄 Connecting to socket for team: $teamId');
    print('🔑 Token: ${token.substring(0, 20)}...');

    // Dispose existing socket if any
    if (_socket.connected) {
      print('🔄 Socket already connected, reconnecting...');
      _socket.disconnect();
      await Future.delayed(Duration(milliseconds: 500));
    }

    try {
      // CRITICAL FIX: Create socket with ALL authentication methods
      _socket = io.io(
        _baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .disableReconnection()
            .setTimeout(60000)
            // 🚨 CRITICAL: Pass token in BOTH auth and query for maximum compatibility
            .setAuth({'token': token}) // Socket.IO v4 auth
            .setQuery({
              'token': token,
            }) // Query parameter (Socket.IO v2/v3 and backup)
            .setExtraHeaders({
              'Authorization': 'Bearer $token', // HTTP headers
            })
            .build(),
      );

      print('🔧 Socket configured with authentication in handshake');

      // Setup listeners
      _setupSocketListeners();

      final completer = Completer<void>();
      final timer = Timer(Duration(seconds: 15), () {
        if (!completer.isCompleted) {
          completer.completeError(
            TimeoutException('Connection timeout after 15 seconds'),
          );
        }
      });

      _socket.once('connect', (_) {
        timer.cancel();
        print('✅ SOCKET CONNECTED ID: ${_socket.id}');
        print('⏳ Waiting for authentication...');
        // Authentication should happen automatically via handshake
        completer.complete();
      });

      _socket.once('connect_error', (error) {
        timer.cancel();
        print('❌ CONNECT ERROR: $error');
        completer.completeError(Exception('Connection failed: $error'));
      });

      _socket.once('connect_timeout', (_) {
        timer.cancel();
        completer.completeError(TimeoutException('Connection timeout'));
      });

      // Connect manually (since we disabled autoConnect)
      print('🔌 Connecting socket with handshake authentication...');
      _socket.connect();

      await completer.future;
    } catch (e) {
      print('❌ CONNECTION ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    print('🔌 Disconnecting socket...');
    _socket.disconnect();
    _isConnected = false;
    _currentTeamId = null;
    _currentToken = null;
  }

  @override
  Future<void> sendMessage(String teamId, String content) async {
    if (!_isConnected) {
      throw Exception('Socket not connected');
    }

    final completer = Completer<void>();
    final timer = Timer(Duration(seconds: 8), () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('Send timeout'));
      }
    });

    print('💬 Sending message to team $teamId: "$content"');

    _socket.emitWithAck(
      'send_message',
      {'teamId': teamId, 'content': content},
      ack: (res) {
        timer.cancel();
        if (res is Map && res['error'] != null) {
          completer.completeError(ServerFailure(res['error']));
        } else {
          print('✅ Message sent successfully');
          completer.complete();
        }
      },
    );

    await completer.future;
  }

  @override
  Future<List<MessageModel>> getTeamMessages(String teamId) async {
    try {
      final authRepository = GetIt.I<AuthRepository>();
      final token = await authRepository.getAccessToken();

      if (token == null) {
        throw ServerFailure('No authentication token found');
      }

      final baseUrl = _baseUrl + '/api/v1';
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
}
