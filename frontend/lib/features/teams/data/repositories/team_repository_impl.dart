// data/repositories/team_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/repositories/team_repository.dart';
import '../datasources/remote/team_remote_data_source.dart';
import '../datasources/local/team_local_data_source.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';

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
      if (await networkInfo.isConnected) {
        final remoteTeams = await remoteDataSource.getUserTeams();
        await localDataSource.cacheTeams(remoteTeams);
        return Right(remoteTeams);
      } else {
        final localTeams = await localDataSource.getCachedTeams();
        return Right(localTeams);
      }
    } on ServerException {
      return Left(ServerFailure());
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<TeamEntity>>> searchTeams(String query) async {
    try {
      final teams = await remoteDataSource.searchTeams(query);
      return Right(teams);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> createTeam(String name, String? logoUrl) async {
    try {
      await remoteDataSource.createTeam(name, logoUrl);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
