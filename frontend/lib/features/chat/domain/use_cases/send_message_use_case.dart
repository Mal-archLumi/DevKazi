// lib/features/chat/domain/usecases/send_message_usecase.dart
import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, void>> call(String teamId, String content) {
    return repository.sendMessage(teamId, content);
  }
}
