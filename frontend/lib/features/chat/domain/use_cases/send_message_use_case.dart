// lib/features/chat/domain/use_cases/send_message_use_case.dart
import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  // FIX: Remove the positional parameter completely
  SendMessageUseCase({required this.repository});

  Future<Either<Failure, void>> call(
    String teamId,
    String content, {
    String? replyToId,
  }) async {
    return await repository.sendMessage(teamId, content, replyToId: replyToId);
  }
}
