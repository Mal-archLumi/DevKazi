// features/teams/domain/use_cases/search_browse_teams_usecase.dart
import 'package:dartz/dartz.dart';
import '/../../core/errors/failures.dart';
import '../entities/team_entity.dart';
import '../repositories/team_repository.dart';

class SearchBrowseTeamsUseCase {
  final TeamRepository repository;

  SearchBrowseTeamsUseCase(this.repository);

  Future<Either<Failure, List<TeamEntity>>> call(String query) async {
    return await repository.searchBrowseTeams(query);
  }
}
