// data/datasources/local/team_local_data_source.dart
import '../../../domain/entities/team_entity.dart';

abstract class TeamLocalDataSource {
  Future<List<TeamEntity>> getCachedTeams();
  Future<void> cacheTeams(List<TeamEntity> teams);
}

class TeamLocalDataSourceImpl implements TeamLocalDataSource {
  // TODO: Add your local storage (Hive, SharedPreferences, etc.)
  List<TeamEntity> _cachedTeams = [];

  @override
  Future<List<TeamEntity>> getCachedTeams() async {
    return _cachedTeams;
  }

  @override
  Future<void> cacheTeams(List<TeamEntity> teams) async {
    _cachedTeams = teams;
  }
}
