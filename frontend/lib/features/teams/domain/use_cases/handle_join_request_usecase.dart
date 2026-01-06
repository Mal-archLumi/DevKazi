// features/teams/domain/usecases/handle_join_request_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/teams/domain/entities/join_request_entity.dart';
import 'package:frontend/features/teams/domain/repositories/team_repository.dart';

class HandleJoinRequestParams {
  final String teamId;
  final String requestId;
  final bool approved;

  HandleJoinRequestParams({
    required this.teamId,
    required this.requestId,
    required this.approved,
  });
}

class HandleJoinRequestUseCase {
  final TeamRepository repository;

  HandleJoinRequestUseCase(this.repository);

  Future<Either<Failure, JoinRequestEntity>> call(
    HandleJoinRequestParams params,
  ) async {
    return await repository.handleJoinRequest(
      teamId: params.teamId,
      requestId: params.requestId,
      approved: params.approved,
    );
  }
}
