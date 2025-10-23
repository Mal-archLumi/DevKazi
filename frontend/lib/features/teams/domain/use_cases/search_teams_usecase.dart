// domain/usecases/search_teams_usecase.dart
import 'package:dartz/dartz.dart';
import '../entities/team_entity.dart';
import '../repositories/team_repository.dart';
import '../../core/errors/failures.dart';

class SearchTeamsUseCase {
  final TeamRepository repository;

  SearchTeamsUseCase(this.repository);

  Future<Either<Failure, List<TeamEntity>>> call(String query) async {
    return await repository.searchTeams(query);
  }
}
