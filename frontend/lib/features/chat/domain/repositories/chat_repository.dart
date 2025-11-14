// lib/features/chat/domain/repositories/chat_repository.dart
import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  /// Stream of incoming messages
  Stream<MessageEntity> get messageStream;

  /// Stream that emits when socket connects
  Stream<void> get onConnected;

  /// Stream that emits when authentication is successful
  Stream<void> get onAuthenticated;

  /// Stream of user online/offline status updates
  Stream<Map<String, dynamic>> get userStatusStream; // ADD THIS

  /// Check if currently connected
  bool get isConnected;

  /// Connect to chat for a specific team
  Future<Either<Failure, void>> connect(String teamId, String token);

  /// Disconnect from chat
  Future<Either<Failure, void>> disconnect();

  /// Send a message to a team
  Future<Either<Failure, void>> sendMessage(String teamId, String content);

  /// Get all messages for a team
  Future<Either<Failure, List<MessageEntity>>> getTeamMessages(String teamId);

  /// Emit a custom event to the server
  void emit(String event, dynamic data); // ADD THIS
}
