// features/teams/domain/usecases/join_team_usecase.dart
import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import '../repositories/team_repository.dart';

class JoinTeamUseCase {
  final TeamRepository repository;

  JoinTeamUseCase(this.repository);

  Future<Either<Failure, bool>> call(String teamId) async {
    return repository.joinTeam(teamId);
  }
}
