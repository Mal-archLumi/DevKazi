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
      log('🟡 TeamRepositoryImpl: Getting user teams...');

      final authRepository = getIt<AuthRepository>();
      final token = await authRepository.getAccessToken();
      log(
        '🟡 TeamRepositoryImpl: Token available for teams request: ${token != null}',
      );

      if (await networkInfo.isConnected) {
        log('🟡 TeamRepositoryImpl: Network connected, fetching from API...');
        final remoteTeams = await remoteDataSource.getUserTeams();
        log(
          '🟢 TeamRepositoryImpl: Successfully fetched ${remoteTeams.length} teams',
        );

        await localDataSource.cacheTeams(remoteTeams);
        log('🟢 TeamRepositoryImpl: Teams cached locally');
        return Right(remoteTeams);
      } else {
        log(
          '🟡 TeamRepositoryImpl: No internet connection, trying cached data...',
        );
        final localTeams = await localDataSource.getCachedTeams();
        if (localTeams.isNotEmpty) {
          log('🟢 TeamRepositoryImpl: Found ${localTeams.length} cached teams');
          return Right(localTeams);
        }
        log('🔴 TeamRepositoryImpl: No cached data available');
        return Left(CacheFailure('No internet connection and no cached data'));
      }
    } on ServerException catch (e) {
      log('🔴 TeamRepositoryImpl: ServerException - ${e.message}');
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      log('🔴 TeamRepositoryImpl: CacheException - ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e, stackTrace) {
      log('🔴 TeamRepositoryImpl: Unexpected error - $e');
      log('🔴 Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TeamEntity>>> searchTeams(String query) async {
    try {
      log('🟡 TeamRepositoryImpl: Checking network connection for search...');
      if (await networkInfo.isConnected) {
        log(
          '🟢 TeamRepositoryImpl: Network connected, searching teams with query: $query',
        );
        final teams = await remoteDataSource.searchTeams(query);
        log(
          '🟢 TeamRepositoryImpl: Successfully searched ${teams.length} teams',
        );
        return Right(teams);
      } else {
        log('🔴 TeamRepositoryImpl: No internet connection for search');
        return Left(CacheFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      log(
        '🔴 TeamRepositoryImpl: ServerException during search - ${e.message}',
      );
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      log('🔴 TeamRepositoryImpl: Unexpected error during search - $e');
      log('🔴 Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, TeamEntity>> createTeam(
    String name,
    String? description,
  ) async {
    try {
      log(
        '🟡 TeamRepositoryImpl: Checking network connection for create team...',
      );
      if (await networkInfo.isConnected) {
        log('🟢 TeamRepositoryImpl: Network connected, creating team: $name');
        final team = await remoteDataSource.createTeam(name, description);
        log('🟢 TeamRepositoryImpl: Team created successfully');
        return Right(team);
      } else {
        log('🔴 TeamRepositoryImpl: No internet connection for create team');
        return Left(CacheFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      log(
        '🔴 TeamRepositoryImpl: ServerException during create team - ${e.message}',
      );
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      log('🔴 TeamRepositoryImpl: Unexpected error during create team - $e');
      log('🔴 Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TeamEntity>>> getAllTeams() async {
    try {
      log(
        '🟡 TeamRepositoryImpl: Checking network connection for get all teams...',
      );
      if (await networkInfo.isConnected) {
        log('🟢 TeamRepositoryImpl: Network connected, fetching all teams...');
        final remoteTeams = await remoteDataSource.getAllTeams();
        log(
          '🟢 TeamRepositoryImpl: Successfully fetched ${remoteTeams.length} teams',
        );
        return Right(remoteTeams);
      } else {
        log('🔴 TeamRepositoryImpl: No internet connection for get all teams');
        return Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      log(
        '🔴 TeamRepositoryImpl: ServerException during get all teams - ${e.message}',
      );
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      log('🔴 TeamRepositoryImpl: Unexpected error during get all teams - $e');
      log('🔴 Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> joinTeam(String teamId) async {
    try {
      log(
        '🟡 TeamRepositoryImpl: Checking network connection for join team...',
      );
      if (await networkInfo.isConnected) {
        log('🟢 TeamRepositoryImpl: Network connected, joining team: $teamId');
        await remoteDataSource.joinTeam(teamId);
        log('🟢 TeamRepositoryImpl: Successfully joined team');
        return const Right(true);
      } else {
        log('🔴 TeamRepositoryImpl: No internet connection for join team');
        return Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      log(
        '🔴 TeamRepositoryImpl: ServerException during join team - ${e.message}',
      );
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      log('🔴 TeamRepositoryImpl: Unexpected error during join team - $e');
      log('🔴 Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TeamEntity>>> getBrowseTeams() async {
    try {
      log(
        '🟡 TeamRepositoryImpl: Checking network connection for get browse teams...',
      );
      if (await networkInfo.isConnected) {
        log(
          '🟢 TeamRepositoryImpl: Network connected, fetching browse teams...',
        );
        final remoteTeams = await remoteDataSource.getBrowseTeams();
        log(
          '🟢 TeamRepositoryImpl: Successfully fetched ${remoteTeams.length} browse teams',
        );
        return Right(remoteTeams);
      } else {
        log(
          '🔴 TeamRepositoryImpl: No internet connection for get browse teams',
        );
        return Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      log(
        '🔴 TeamRepositoryImpl: ServerException during get browse teams - ${e.message}',
      );
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      log(
        '🔴 TeamRepositoryImpl: Unexpected error during get browse teams - $e',
      );
      log('🔴 Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
