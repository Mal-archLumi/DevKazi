// features/teams/domain/use_cases/get_pending_requests_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/teams/domain/entities/join_request_entity.dart';
import 'package:frontend/features/teams/domain/repositories/team_repository.dart';

class GetPendingRequestsUseCase {
  final TeamRepository repository;

  GetPendingRequestsUseCase({required this.repository});

  Future<Either<Failure, List<JoinRequestEntity>>> call() async {
    return await repository.getMyPendingRequests();
  }
}
