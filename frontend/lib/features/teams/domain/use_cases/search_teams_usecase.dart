// domain/usecases/search_teams_usecase.dart
import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import '../entities/team_entity.dart';
import '../repositories/team_repository.dart';

class SearchTeamsUseCase {
  final TeamRepository repository;

  SearchTeamsUseCase(this.repository);

  Future<Either<Failure, List<TeamEntity>>> call(String query) async {
    return await repository.searchTeams(query);
  }
}
