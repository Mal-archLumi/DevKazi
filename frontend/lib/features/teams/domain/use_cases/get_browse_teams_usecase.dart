// features/teams/domain/usecases/get_browse_teams_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:frontend/core/errors/failures.dart';
import '../entities/team_entity.dart';
import '../repositories/team_repository.dart';

class GetBrowseTeamsUseCase {
  final TeamRepository repository;

  GetBrowseTeamsUseCase(this.repository);

  Future<Future<Either<Failure, List<TeamEntity>>>> call() async {
    return repository.getBrowseTeams();
  }
}
