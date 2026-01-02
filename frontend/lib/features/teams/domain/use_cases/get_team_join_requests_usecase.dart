import 'package:dartz/dartz.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/teams/domain/entities/join_request_entity.dart';
import 'package:frontend/features/teams/domain/repositories/team_repository.dart';

class GetTeamJoinRequestsUseCase {
  final TeamRepository repository;

  GetTeamJoinRequestsUseCase(this.repository);

  Future<Either<Failure, List<JoinRequestEntity>>> call(String teamId) async {
    return await repository.getTeamJoinRequests(teamId);
  }
}
