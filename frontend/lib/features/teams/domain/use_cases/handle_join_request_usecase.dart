// features/teams/domain/usecases/handle_join_request_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/teams/domain/repositories/team_repository.dart';

class HandleJoinRequestParams {
  final String requestId;
  final String action; // 'approve' or 'reject'

  HandleJoinRequestParams({required this.requestId, required this.action});
}

class HandleJoinRequestUseCase {
  final TeamRepository repository;

  HandleJoinRequestUseCase(this.repository);

  Future<Either<Failure, bool>> call(HandleJoinRequestParams params) async {
    return await repository.handleJoinRequest(params.requestId, params.action);
  }
}
