// features/teams/domain/repositories/team_repository.dart
import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import '../entities/team_entity.dart';
import '../entities/join_request_entity.dart';

abstract class TeamRepository {
  Future<Either<Failure, List<TeamEntity>>> getUserTeams();
  Future<Either<Failure, List<TeamEntity>>> searchTeams(String query);
  Future<Either<Failure, TeamEntity>> createTeam({
    required String name,
    required String description,
    required List<String> skills,
    int? maxMembers,
  });
  Future<Either<Failure, List<TeamEntity>>> getAllTeams();
  Future<Either<Failure, bool>> requestToJoinTeam(String teamId);
  Future<Either<Failure, List<TeamEntity>>> searchBrowseTeams(String query);
  Future<Either<Failure, TeamEntity>> getTeamById(String teamId);
  Future<Either<Failure, void>> leaveTeam(String teamId);

  // Join request methods
  Future<Either<Failure, List<JoinRequestEntity>>> getJoinRequests(
    String teamId,
  );
  Future<Either<Failure, JoinRequestEntity>> handleJoinRequest({
    required String teamId,
    required String requestId,
    required bool approved,
    String? message,
  });
  Future<Either<Failure, void>> cancelJoinRequest(String requestId);

  // Added: get my pending join requests
  Future<Either<Failure, List<JoinRequestEntity>>> getMyPendingRequests();

  Future<Either<Failure, List<JoinRequestEntity>>> getTeamJoinRequests(
    String teamId,
  );
  Future<Either<Failure, bool>> approveOrRejectJoinRequest({
    required String requestId,
    required String action,
    String? message,
  });
}
