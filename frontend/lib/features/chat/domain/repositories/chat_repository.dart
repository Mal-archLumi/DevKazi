// lib/features/chat/domain/repositories/chat_repository.dart
import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Stream<MessageEntity> get messageStream;
  Stream<void> get onConnected;
  Stream<void> get onAuthenticated;
  Stream<Map<String, dynamic>> get userStatusStream;

  Future<Either<Failure, void>> connect(String teamId, String token);
  Future<Either<Failure, void>> disconnect();

  // UPDATE: Add replyToId parameter
  Future<Either<Failure, void>> sendMessage(
    String teamId,
    String content, {
    String? replyToId,
  });

  Future<Either<Failure, List<MessageEntity>>> getTeamMessages(String teamId);
  Future<Either<Failure, void>> deleteMessages(
    String teamId,
    List<String> messageIds,
  );

  bool get isConnected;
  void emit(String event, dynamic data);
}
