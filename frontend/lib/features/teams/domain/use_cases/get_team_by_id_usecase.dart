// features/teams/domain/use_cases/get_team_by_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/teams/domain/entities/team_entity.dart';
import 'package:frontend/features/teams/domain/repositories/team_repository.dart';

class GetTeamByIdUseCase {
  final TeamRepository repository;

  GetTeamByIdUseCase({required this.repository});

  Future<Either<Failure, TeamEntity>> call(String teamId) async {
    return await repository.getTeamById(teamId);
  }
}
