// domain/usecases/get_user_teams_usecase.dart
import 'package:dartz/dartz.dart';
import '../entities/team_entity.dart';
import '../repositories/team_repository.dart';
import '/../core/errors/failures.dart';

class GetUserTeamsUseCase {
  final TeamRepository repository;

  GetUserTeamsUseCase(this.repository);

  Future<Either<Failure, List<TeamEntity>>> call() async {
    return await repository.getUserTeams();
  }
}
