// lib/features/chat/domain/usecases/get_messages_usecase.dart
import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/chat/domain/entities/message_entity.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Future<Either<Failure, List<MessageEntity>>> call(
    String teamId, {
    String? token,
  }) async {
    return await repository.getTeamMessages(teamId, token: token);
  }
}
