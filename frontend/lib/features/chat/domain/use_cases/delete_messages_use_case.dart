// lib/features/chat/domain/use_cases/delete_messages_use_case.dart
import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';

class DeleteMessagesUseCase {
  final ChatRepository repository;

  DeleteMessagesUseCase({required this.repository});

  Future<Either<Failure, void>> call(
    String teamId,
    List<String> messageIds,
  ) async {
    return await repository.deleteMessages(teamId, messageIds);
  }
}
