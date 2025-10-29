// domain/usecases/create_team_usecase.dart
import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import '../entities/team_entity.dart';
import '../repositories/team_repository.dart';

class CreateTeamUseCase {
  final TeamRepository repository;

  CreateTeamUseCase(this.repository);

  Future<Either<Failure, TeamEntity>> call(
    String name,
    String? description,
  ) async {
    return repository.createTeam(name, description);
  }
}
