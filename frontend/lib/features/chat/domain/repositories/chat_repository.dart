// lib/features/chat/domain/repositories/chat_repository.dart
import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Stream<MessageEntity> get messageStream;
  Stream<void> get onAuthenticated;
  Future<Either<Failure, void>> connect(String teamId, String token);
  Future<Either<Failure, void>> disconnect();
  Future<Either<Failure, void>> sendMessage(String teamId, String content);
  Future<Either<Failure, List<MessageEntity>>> getTeamMessages(String teamId);
  bool get isConnected;
}
