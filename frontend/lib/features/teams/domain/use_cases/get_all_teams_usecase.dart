// features/teams/domain/usecases/get_all_teams_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:frontend/core/errors/failures.dart';
import '../entities/team_entity.dart';
import '../repositories/team_repository.dart';

class GetAllTeamsUseCase {
  final TeamRepository repository;

  GetAllTeamsUseCase(this.repository);

  Future<Either<Failure, List<TeamEntity>>> call() async {
    return repository.getAllTeams();
  }
}
