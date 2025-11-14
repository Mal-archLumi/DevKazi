// domain/repositories/team_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/team_entity.dart';
import '/../core/errors/failures.dart';

abstract class TeamRepository {
  Future<Either<Failure, List<TeamEntity>>> getUserTeams();
  Future<Either<Failure, List<TeamEntity>>> searchTeams(String query);
  Future<Either<Failure, TeamEntity>> createTeam(
    String name,
    String? description,
  );
  Future<Either<Failure, List<TeamEntity>>> getAllTeams();
  Future<Either<Failure, bool>> joinTeam(String teamId);
  Future<Either<Failure, TeamEntity>> getTeamById(String teamId);
}
