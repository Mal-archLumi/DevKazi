// data/repositories/team_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:frontend/core/injection_container.dart';
import 'package:frontend/features/teams/data/models/join_request_model.dart';
import 'dart:developer';
import '../../domain/entities/team_entity.dart';
import '../../domain/entities/join_request_entity.dart';
import '../../domain/repositories/team_repository.dart';
import '../data_sources/remote/team_remote_data_source.dart';
import '../data_sources/local/team_local_data_source.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class TeamRepositoryImpl implements TeamRepository {
  final TeamRemoteDataSource remoteDataSource;
  final TeamLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TeamRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<TeamEntity>>> getUserTeams() async {
    try {
      log('🟡 TeamRepositoryImpl.getUserTeams: Starting...');

      final authRepository = getIt<AuthRepository>();
      final token = await authRepository.getAccessToken();
      log(
        '🟡 TeamRepositoryImpl.getUserTeams: Token available: ${token != null}',
      );

      if (await networkInfo.isConnected) {
        log(
          '🟡 TeamRepositoryImpl.getUserTeams: Network connected, fetching from API...',
        );
        final remoteTeams = await remoteDataSource.getUserTeams();
        log(
          '🟢 TeamRepositoryImpl.getUserTeams: Successfully fetched ${remoteTeams.length} teams',
        );

        for (var team in remoteTeams) {
          log(
            '🟢 TeamRepositoryImpl.getUserTeams: Team - ${team.name} (${team.id})',
          );
        }

        await localDataSource.cacheTeams(remoteTeams);
        log('🟢 TeamRepositoryImpl.getUserTeams: Teams cached locally');
        return Right(remoteTeams);
      } else {
        log(
          '🟡 TeamRepositoryImpl.getUserTeams: No internet connection, trying cached data...',
        );
        final localTeams = await localDataSource.getCachedTeams();
        if (localTeams.isNotEmpty) {
          log(
            '🟢 TeamRepositoryImpl.getUserTeams: Found ${localTeams.length} cached teams',
          );
          return Right(localTeams);
        }
        log('🔴 TeamRepositoryImpl.getUserTeams: No cached data available');
        return Left(CacheFailure('No internet connection and no cached data'));
      }
    } on ServerException catch (e) {
      log('🔴 TeamRepositoryImpl.getUserTeams: ServerException - ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      log('🔴 TeamRepositoryImpl.getUserTeams: Unexpected error - $e');
      log('🔴 TeamRepositoryImpl.getUserTeams: Stack trace: $stackTrace');

      if (e is CacheException) {
        return Left(CacheFailure(e.message));
      }
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TeamEntity>>> searchTeams(String query) async {
    try {
      log(
        '🟡 TeamRepositoryImpl.searchTeams: Starting search with query: "$query"',
      );

      if (await networkInfo.isConnected) {
        log(
          '🟢 TeamRepositoryImpl.searchTeams: Network connected, calling remote data source...',
        );

        final teams = await remoteDataSource.searchTeams(query);
        log('🟢 TeamRepositoryImpl.searchTeams: Found ${teams.length} teams');

        return Right(teams);
      } else {
        log(
          '🔴 TeamRepositoryImpl.searchTeams: No internet connection for search',
        );
        return Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      log('🔴 TeamRepositoryImpl.searchTeams: ServerException - ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      log('🔴 TeamRepositoryImpl.searchTeams: Unexpected error - $e');
      log('🔴 TeamRepositoryImpl.searchTeams: Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error during search: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TeamEntity>>> searchBrowseTeams(
    String query,
  ) async {
    try {
      log(
        '🟡 TeamRepositoryImpl.searchBrowseTeams: Starting search with query: "$query"',
      );

      if (await networkInfo.isConnected) {
        final teams = await remoteDataSource.searchBrowseTeams(query);
        log(
          '🟢 TeamRepositoryImpl.searchBrowseTeams: Found ${teams.length} teams',
        );
        return Right(teams);
      } else {
        log('🔴 TeamRepositoryImpl.searchBrowseTeams: No internet connection');
        return Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      log(
        '🔴 TeamRepositoryImpl.searchBrowseTeams: ServerException - ${e.message}',
      );
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      log('🔴 TeamRepositoryImpl.searchBrowseTeams: Unexpected error - $e');
      log('🔴 TeamRepositoryImpl.searchBrowseTeams: Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error during search: $e'));
    }
  }

  @override
  Future<Either<Failure, TeamEntity>> createTeam({
    required String name,
    required String description,
    required List<String> skills,
    int? maxMembers,
  }) async {
    try {
      log('🟡 TeamRepositoryImpl.createTeam: Creating team: "$name"');

      if (await networkInfo.isConnected) {
        final team = await remoteDataSource.createTeam(
          name: name,
          description: description,
          skills: skills,
          maxMembers: maxMembers,
        );
        log(
          '🟢 TeamRepositoryImpl.createTeam: Team created successfully: ${team.name} (${team.id})',
        );
        return Right(team);
      } else {
        log('🔴 TeamRepositoryImpl.createTeam: No internet connection');
        return Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      log('🔴 TeamRepositoryImpl.createTeam: ServerException - ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      log('🔴 TeamRepositoryImpl.createTeam: Unexpected error - $e');
      log('🔴 TeamRepositoryImpl.createTeam: Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TeamEntity>>> getAllTeams() async {
    try {
      log('🟡 TeamRepositoryImpl.getAllTeams: Starting...');

      if (await networkInfo.isConnected) {
        final remoteTeams = await remoteDataSource.getAllTeams();
        log(
          '🟢 TeamRepositoryImpl.getAllTeams: Successfully fetched ${remoteTeams.length} teams',
        );
        return Right(remoteTeams);
      } else {
        log('🔴 TeamRepositoryImpl.getAllTeams: No internet connection');
        return Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      log('🔴 TeamRepositoryImpl.getAllTeams: ServerException - ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      log('🔴 TeamRepositoryImpl.getAllTeams: Unexpected error - $e');
      log('🔴 TeamRepositoryImpl.getAllTeams: Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> joinTeam(String teamId) async {
    try {
      log('🟡 TeamRepositoryImpl.joinTeam: Joining team with ID: $teamId');

      if (await networkInfo.isConnected) {
        await remoteDataSource.joinTeam(teamId);
        log(
          '🟢 TeamRepositoryImpl.joinTeam: Successfully joined team: $teamId',
        );
        return const Right(true);
      } else {
        log('🔴 TeamRepositoryImpl.joinTeam: No internet connection');
        return Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      log('🔴 TeamRepositoryImpl.joinTeam: ServerException - ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      log('🔴 TeamRepositoryImpl.joinTeam: Unexpected error - $e');
      log('🔴 TeamRepositoryImpl.joinTeam: Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, TeamEntity>> getTeamById(String teamId) async {
    try {
      log('🟡 TeamRepositoryImpl.getTeamById: Getting team by ID: $teamId');

      if (await networkInfo.isConnected) {
        final remoteTeam = await remoteDataSource.getTeamById(teamId);
        log(
          '🟢 TeamRepositoryImpl.getTeamById: Successfully fetched team: ${remoteTeam.name}',
        );
        return Right(remoteTeam);
      } else {
        log('🔴 TeamRepositoryImpl.getTeamById: No internet connection');
        return Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      log('🔴 TeamRepositoryImpl.getTeamById: ServerException - ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      log('🔴 TeamRepositoryImpl.getTeamById: Unexpected error - $e');
      log('🔴 TeamRepositoryImpl.getTeamById: Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> leaveTeam(String teamId) async {
    try {
      log('🟡 TeamRepositoryImpl.leaveTeam: Leaving team with ID: $teamId');

      if (await networkInfo.isConnected) {
        await remoteDataSource.leaveTeam(teamId);
        log('🟢 TeamRepositoryImpl.leaveTeam: Successfully left team: $teamId');
        return const Right(true);
      } else {
        log('🔴 TeamRepositoryImpl.leaveTeam: No internet connection');
        return Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      log('🔴 TeamRepositoryImpl.leaveTeam: ServerException - ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      log('🔴 TeamRepositoryImpl.leaveTeam: Unexpected error - $e');
      log('🔴 TeamRepositoryImpl.leaveTeam: Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestToJoinTeam(String teamId) async {
    try {
      log(
        '🟡 TeamRepositoryImpl.requestToJoinTeam: Requesting to join team: $teamId',
      );

      if (await networkInfo.isConnected) {
        await remoteDataSource.requestToJoinTeam(teamId);
        log(
          '🟢 TeamRepositoryImpl.requestToJoinTeam: Successfully requested to join team',
        );
        return const Right(true);
      } else {
        log('🔴 TeamRepositoryImpl.requestToJoinTeam: No internet connection');
        return Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      log(
        '🔴 TeamRepositoryImpl.requestToJoinTeam: ServerException - ${e.message}',
      );
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      log('🔴 TeamRepositoryImpl.requestToJoinTeam: Unexpected error - $e');
      log('🔴 TeamRepositoryImpl.requestToJoinTeam: Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<JoinRequestEntity>>> getJoinRequests(
    String teamId,
  ) async {
    try {
      log(
        '🟡 TeamRepositoryImpl.getJoinRequests: Getting join requests for team: $teamId',
      );

      if (await networkInfo.isConnected) {
        final joinRequests = await remoteDataSource.getJoinRequests(teamId);
        log(
          '🟢 TeamRepositoryImpl.getJoinRequests: Successfully fetched ${joinRequests.length} join requests',
        );
        return Right(joinRequests);
      } else {
        log('🔴 TeamRepositoryImpl.getJoinRequests: No internet connection');
        return Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      log(
        '🔴 TeamRepositoryImpl.getJoinRequests: ServerException - ${e.message}',
      );
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      log('🔴 TeamRepositoryImpl.getJoinRequests: Unexpected error - $e');
      log('🔴 TeamRepositoryImpl.getJoinRequests: Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, JoinRequestEntity>> handleJoinRequest({
    required String teamId,
    required String requestId,
    required bool approved,
    String? message,
  }) async {
    try {
      log(
        '🟡 TeamRepositoryImpl.handleJoinRequest: Handling request $requestId (approved: $approved)',
      );

      if (await networkInfo.isConnected) {
        final authRepository = getIt<AuthRepository>();
        final token = await authRepository.getAccessToken();

        if (token == null) {
          log('🔴 TeamRepositoryImpl.handleJoinRequest: No access token');
          return Left(AuthFailure('Not authenticated'));
        }

        // FIX: Use remoteDataSource instead of direct client call
        final joinRequest = await remoteDataSource.handleJoinRequest(
          teamId: teamId,
          requestId: requestId,
          approved: approved,
          message: message,
        );

        log(
          '🟢 TeamRepositoryImpl.handleJoinRequest: Join request handled successfully',
        );
        return Right(joinRequest);
      } else {
        log('🔴 TeamRepositoryImpl.handleJoinRequest: No internet connection');
        return Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      log(
        '🔴 TeamRepositoryImpl.handleJoinRequest: ServerException - ${e.message}',
      );
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      log('🔴 TeamRepositoryImpl.handleJoinRequest: Unexpected error - $e');
      log('🔴 TeamRepositoryImpl.handleJoinRequest: Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> approveOrRejectJoinRequest({
    required String requestId,
    required String action,
    String? message,
  }) async {
    try {
      log(
        '🟡 TeamRepositoryImpl.approveOrRejectJoinRequest: Approving/rejecting request $requestId with action: $action',
      );

      if (await networkInfo.isConnected) {
        await remoteDataSource.approveOrRejectJoinRequest(
          requestId: requestId,
          action: action,
          message: message,
        );
        log(
          '🟢 TeamRepositoryImpl.approveOrRejectJoinRequest: Successfully handled request',
        );
        return const Right(true);
      } else {
        log(
          '🔴 TeamRepositoryImpl.approveOrRejectJoinRequest: No internet connection',
        );
        return Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      log(
        '🔴 TeamRepositoryImpl.approveOrRejectJoinRequest: ServerException - ${e.message}',
      );
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      log(
        '🔴 TeamRepositoryImpl.approveOrRejectJoinRequest: Unexpected error - $e',
      );
      log(
        '🔴 TeamRepositoryImpl.approveOrRejectJoinRequest: Stack trace: $stackTrace',
      );
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelJoinRequest(String requestId) async {
    try {
      log(
        '🟡 TeamRepositoryImpl.cancelJoinRequest: Canceling request $requestId',
      );

      if (await networkInfo.isConnected) {
        await remoteDataSource.cancelJoinRequest(requestId);
        log('🟢 TeamRepositoryImpl.cancelJoinRequest: Successfully canceled');
        return const Right(null);
      } else {
        log('🔴 TeamRepositoryImpl.cancelJoinRequest: No internet connection');
        return Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      log(
        '🔴 TeamRepositoryImpl.cancelJoinRequest: ServerException - ${e.message}',
      );
      return Left(ServerFailure(e.message));
    } catch (e) {
      log('🔴 TeamRepositoryImpl.cancelJoinRequest: Unexpected error - $e');
      return Left(ServerFailure('Failed to cancel join request: $e'));
    }
  }

  @override
  Future<Either<Failure, List<JoinRequestEntity>>>
  getMyPendingRequests() async {
    try {
      log('🟡 TeamRepositoryImpl.getMyPendingRequests: Fetching...');

      if (await networkInfo.isConnected) {
        final requests = await remoteDataSource.getMyPendingRequests();
        log(
          '🟢 TeamRepositoryImpl.getMyPendingRequests: Got ${requests.length} requests',
        );
        return Right(requests);
      } else {
        log(
          '🔴 TeamRepositoryImpl.getMyPendingRequests: No internet connection',
        );
        return Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      log(
        '🔴 TeamRepositoryImpl.getMyPendingRequests: ServerException - ${e.message}',
      );
      return Left(ServerFailure(e.message));
    } catch (e) {
      log('🔴 TeamRepositoryImpl.getMyPendingRequests: Unexpected error - $e');
      return Left(ServerFailure('Failed to get pending requests: $e'));
    }
  }

  @override
  Future<Either<Failure, List<JoinRequestEntity>>> getTeamJoinRequests(
    String teamId,
  ) async {
    try {
      log(
        '🟡 TeamRepositoryImpl.getTeamJoinRequests: Fetching for team $teamId',
      );

      if (await networkInfo.isConnected) {
        final authRepository = getIt<AuthRepository>();
        final token = await authRepository.getAccessToken();

        if (token == null) {
          log('🔴 TeamRepositoryImpl.getTeamJoinRequests: No access token');
          return Left(AuthFailure('Not authenticated'));
        }

        final requests = await remoteDataSource.getJoinRequests(teamId);
        log(
          '🟢 TeamRepositoryImpl.getTeamJoinRequests: Got ${requests.length} requests',
        );
        return Right(requests);
      } else {
        log(
          '🔴 TeamRepositoryImpl.getTeamJoinRequests: No internet connection',
        );
        return Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      log(
        '🔴 TeamRepositoryImpl.getTeamJoinRequests: ServerException - ${e.message}',
      );
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      log('🔴 TeamRepositoryImpl.getTeamJoinRequests: Error - $e');
      log('🔴 Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
