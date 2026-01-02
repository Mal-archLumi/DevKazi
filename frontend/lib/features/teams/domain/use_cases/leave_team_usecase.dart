// features/teams/domain/usecases/leave_team_usecase.dart
import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import '../repositories/team_repository.dart';

class LeaveTeamUseCase {
  final TeamRepository repository;

  LeaveTeamUseCase(this.repository);

  Future<Either<Failure, void>> call(String teamId) async {
    return repository.leaveTeam(teamId);
  }
}
