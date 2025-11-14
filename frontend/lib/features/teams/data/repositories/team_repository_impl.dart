// data/repositories/team_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:frontend/core/injection_container.dart';
import 'dart:developer';
import '../../domain/entities/team_entity.dart';
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
  Future<Either<Failure, TeamEntity>> createTeam(
    String name,
    String? description,
  ) async {
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

        final team = await remoteDataSource.createTeam(name, description);
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
}
