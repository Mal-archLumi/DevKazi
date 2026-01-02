// data/repositories/team_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:frontend/core/injection_container.dart';
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

        // Log team names for debugging
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

      // Handle cache exceptions and other unexpected errors
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
      log('🟡 TeamRepositoryImpl.searchTeams: Checking network connection...');

      if (await networkInfo.isConnected) {
        log(
          '🟢 TeamRepositoryImpl.searchTeams: Network connected, calling remote data source...',
        );

        final authRepository = getIt<AuthRepository>();
        final token = await authRepository.getAccessToken();
        log(
          '🟡 TeamRepositoryImpl.searchTeams: Token available for search: ${token != null}',
        );

        final teams = await remoteDataSource.searchTeams(query);
        log(
          '🟢 TeamRepositoryImpl.searchTeams: Search completed for query: "$query"',
        );
        log('🟢 TeamRepositoryImpl.searchTeams: Found ${teams.length} teams');

        // Log detailed team information for debugging
        if (teams.isEmpty) {
          log(
            '🟡 TeamRepositoryImpl.searchTeams: No teams found for query: "$query"',
          );
        } else {
          log(
            '🟢 TeamRepositoryImpl.searchTeams: Teams found for query "$query":',
          );
          for (var i = 0; i < teams.length; i++) {
            final team = teams[i];
            log(
              '🟢 TeamRepositoryImpl.searchTeams: [$i] ${team.name} (ID: ${team.id}) - Members: ${team.memberCount}',
            );
            if (team.description != null) {
              log(
                '🟢 TeamRepositoryImpl.searchTeams:     Description: ${team.description}',
              );
            }
          }
        }

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
      log(
        '🟡 TeamRepositoryImpl.searchBrowseTeams: Checking network connection...',
      );

      if (await networkInfo.isConnected) {
        log(
          '🟢 TeamRepositoryImpl.searchBrowseTeams: Network connected, calling remote data source...',
        );

        final authRepository = getIt<AuthRepository>();
        final token = await authRepository.getAccessToken();
        log(
          '🟡 TeamRepositoryImpl.searchBrowseTeams: Token available: ${token != null}',
        );

        final teams = await remoteDataSource.searchBrowseTeams(query);

        log(
          '🟢 TeamRepositoryImpl.searchBrowseTeams: Search completed for query: "$query"',
        );
        log(
          '🟢 TeamRepositoryImpl.searchBrowseTeams: Found ${teams.length} teams',
        );

        // Log detailed team information for debugging
        if (teams.isEmpty) {
          log(
            '🟡 TeamRepositoryImpl.searchBrowseTeams: No teams found for query: "$query"',
          );
        } else {
          log(
            '🟢 TeamRepositoryImpl.searchBrowseTeams: Teams found for query "$query":',
          );
          for (var i = 0; i < teams.length; i++) {
            final team = teams[i];
            log(
              '🟢 TeamRepositoryImpl.searchBrowseTeams: [$i] ${team.name} (ID: ${team.id}) - Members: ${team.memberCount}',
            );
            if (team.description != null) {
              log(
                '🟢 TeamRepositoryImpl.searchBrowseTeams:     Description: ${team.description}',
              );
            }
          }
        }

        return Right(teams);
      } else {
        log(
          '🔴 TeamRepositoryImpl.searchBrowseTeams: No internet connection for search',
        );
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
      log('🟡 TeamRepositoryImpl.createTeam: Checking network connection...');

      if (await networkInfo.isConnected) {
        log(
          '🟢 TeamRepositoryImpl.createTeam: Network connected, creating team...',
        );

        final authRepository = getIt<AuthRepository>();
        final token = await authRepository.getAccessToken();
        log(
          '🟡 TeamRepositoryImpl.createTeam: Token available: ${token != null}',
        );

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
      log('🟡 TeamRepositoryImpl.getAllTeams: Checking network connection...');

      if (await networkInfo.isConnected) {
        log(
          '🟢 TeamRepositoryImpl.getAllTeams: Network connected, fetching all teams...',
        );

        final authRepository = getIt<AuthRepository>();
        final token = await authRepository.getAccessToken();
        log(
          '🟡 TeamRepositoryImpl.getAllTeams: Token available: ${token != null}',
        );

        final remoteTeams = await remoteDataSource.getAllTeams();
        log(
          '🟢 TeamRepositoryImpl.getAllTeams: Successfully fetched ${remoteTeams.length} teams',
        );

        // Log team names for debugging
        for (var team in remoteTeams) {
          log(
            '🟢 TeamRepositoryImpl.getAllTeams: Team - ${team.name} (${team.id})',
          );
        }

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
      log('🟡 TeamRepositoryImpl.joinTeam: Checking network connection...');

      if (await networkInfo.isConnected) {
        log(
          '🟢 TeamRepositoryImpl.joinTeam: Network connected, joining team...',
        );

        final authRepository = getIt<AuthRepository>();
        final token = await authRepository.getAccessToken();
        log(
          '🟡 TeamRepositoryImpl.joinTeam: Token available: ${token != null}',
        );

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
      log('🟡 TeamRepositoryImpl.getTeamById: Checking network connection...');

      if (await networkInfo.isConnected) {
        log(
          '🟢 TeamRepositoryImpl.getTeamById: Network connected, fetching team...',
        );

        final authRepository = getIt<AuthRepository>();
        final token = await authRepository.getAccessToken();
        log(
          '🟡 TeamRepositoryImpl.getTeamById: Token available: ${token != null}',
        );

        final remoteTeam = await remoteDataSource.getTeamById(teamId);
        log(
          '🟢 TeamRepositoryImpl.getTeamById: Successfully fetched team: ${remoteTeam.name} (${remoteTeam.id})',
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
      log('🟡 TeamRepositoryImpl.leaveTeam: Checking network connection...');

      if (await networkInfo.isConnected) {
        log(
          '🟢 TeamRepositoryImpl.leaveTeam: Network connected, leaving team...',
        );

        final authRepository = getIt<AuthRepository>();
        final token = await authRepository.getAccessToken();
        log(
          '🟡 TeamRepositoryImpl.leaveTeam: Token available: ${token != null}',
        );

        await remoteDataSource.leaveTeam(teamId);
        log('🟢 TeamRepositoryImpl.leaveTeam: Successfully left team: $teamId');
        return const Right(true);
      } else {
        log('🔴 TeamRepositoryImpl.leaveTeam: No internet connection');
        return Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      log('🔴 TeamRepositoryImpl.leaveTeam: ServerException - ${e.message}');
      log(
        '🔴 TeamRepositoryImpl.leaveTeam: ServerException type: ${e.runtimeType}',
      );
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
        '🟡 TeamRepositoryImpl.requestToJoinTeam: Requesting to join team with ID: $teamId',
      );
      log(
        '🟡 TeamRepositoryImpl.requestToJoinTeam: Checking network connection...',
      );

      if (await networkInfo.isConnected) {
        log(
          '🟢 TeamRepositoryImpl.requestToJoinTeam: Network connected, requesting to join team...',
        );

        final authRepository = getIt<AuthRepository>();
        final token = await authRepository.getAccessToken();
        log(
          '🟡 TeamRepositoryImpl.requestToJoinTeam: Token available: ${token != null}',
        );

        await remoteDataSource.requestToJoinTeam(teamId);
        log(
          '🟢 TeamRepositoryImpl.requestToJoinTeam: Successfully requested to join team: $teamId',
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
        '🟡 TeamRepositoryImpl.getJoinRequests: Getting join requests for team ID: $teamId',
      );
      log(
        '🟡 TeamRepositoryImpl.getJoinRequests: Checking network connection...',
      );

      if (await networkInfo.isConnected) {
        log(
          '🟢 TeamRepositoryImpl.getJoinRequests: Network connected, fetching join requests...',
        );

        final authRepository = getIt<AuthRepository>();
        final token = await authRepository.getAccessToken();
        log(
          '🟡 TeamRepositoryImpl.getJoinRequests: Token available: ${token != null}',
        );

        final joinRequests = await remoteDataSource.getJoinRequests(teamId);
        log(
          '🟢 TeamRepositoryImpl.getJoinRequests: Successfully fetched ${joinRequests.length} join requests for team: $teamId',
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
        '🟡 TeamRepositoryImpl.handleJoinRequest: Handling join request $requestId with approved: $approved',
      );
      log(
        '🟡 TeamRepositoryImpl.handleJoinRequest: Checking network connection...',
      );

      if (await networkInfo.isConnected) {
        log(
          '🟢 TeamRepositoryImpl.handleJoinRequest: Network connected, handling join request...',
        );

        final authRepository = getIt<AuthRepository>();
        final token = await authRepository.getAccessToken();
        log(
          '🟡 TeamRepositoryImpl.handleJoinRequest: Token available: ${token != null}',
        );

        final joinRequest = await remoteDataSource.handleJoinRequest(
          teamId: teamId,
          requestId: requestId,
          approved: approved,
          message: message,
        );
        log(
          '🟢 TeamRepositoryImpl.handleJoinRequest: Successfully handled join request $requestId',
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
  Future<Either<Failure, void>> cancelJoinRequest(String requestId) async {
    try {
      await remoteDataSource.cancelJoinRequest(requestId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to cancel join request: $e'));
    }
  }

  @override
  Future<Either<Failure, List<JoinRequestEntity>>>
  getMyPendingRequests() async {
    try {
      final requests = await remoteDataSource.getMyPendingRequests();
      return Right(requests);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get pending requests: $e'));
    }
  }

  @override
  Future<Either<Failure, List<JoinRequestEntity>>> getTeamJoinRequests(
    String teamId,
  ) async {
    try {
      log(
        '🟡 TeamRepositoryImpl.getTeamJoinRequests: Getting join requests for team ID: $teamId',
      );
      log(
        '🟡 TeamRepositoryImpl.getTeamJoinRequests: Checking network connection...',
      );

      if (await networkInfo.isConnected) {
        log(
          '🟢 TeamRepositoryImpl.getTeamJoinRequests: Network connected, fetching join requests...',
        );

        final authRepository = getIt<AuthRepository>();
        final token = await authRepository.getAccessToken();
        log(
          '🟡 TeamRepositoryImpl.getTeamJoinRequests: Token available: ${token != null}',
        );

        final joinRequests = await remoteDataSource.getJoinRequests(teamId);
        log(
          '🟢 TeamRepositoryImpl.getTeamJoinRequests: Successfully fetched ${joinRequests.length} join requests for team: $teamId',
        );
        return Right(joinRequests);
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
      log('🔴 TeamRepositoryImpl.getTeamJoinRequests: Unexpected error - $e');
      log(
        '🔴 TeamRepositoryImpl.getTeamJoinRequests: Stack trace: $stackTrace',
      );
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, JoinRequestEntity>> approveOrRejectJoinRequest({
    required String requestId,
    required String action, // 'approve' or 'reject'
    String? message,
  }) async {
    try {
      log(
        '🟡 TeamRepositoryImpl.approveOrRejectJoinRequest: $action request $requestId',
      );
      log(
        '🟡 TeamRepositoryImpl.approveOrRejectJoinRequest: Checking network connection...',
      );

      if (await networkInfo.isConnected) {
        log(
          '🟢 TeamRepositoryImpl.approveOrRejectJoinRequest: Network connected, processing request...',
        );

        final authRepository = getIt<AuthRepository>();
        final token = await authRepository.getAccessToken();
        log(
          '🟡 TeamRepositoryImpl.approveOrRejectJoinRequest: Token available: ${token != null}',
        );

        final joinRequest = await remoteDataSource.approveOrRejectJoinRequest(
          requestId: requestId,
          action: action,
          message: message,
        );
        log(
          '🟢 TeamRepositoryImpl.approveOrRejectJoinRequest: Successfully processed request $requestId',
        );
        return Right(joinRequest);
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
}
