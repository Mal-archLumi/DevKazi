// data/datasources/remote/team_remote_data_source.dart
import '../../../domain/entities/team_entity.dart';
import '../../models/team_model.dart';

abstract class TeamRemoteDataSource {
  Future<List<TeamEntity>> getUserTeams();
  Future<List<TeamEntity>> searchTeams(String query);
  Future<void> createTeam(String name, String? logoUrl);
}

class TeamRemoteDataSourceImpl implements TeamRemoteDataSource {
  // TODO: Add your HTTP client (Dio, http, etc.)
  // final HttpClient client;

  // TeamRemoteDataSourceImpl({required this.client});

  @override
  Future<List<TeamEntity>> getUserTeams() async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // Mock data for now
    return [
      TeamModel(
        id: '1',
        name: 'Google Team',
        logoUrl: null,
        initial: 'G',
        memberCount: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      TeamModel(
        id: '2',
        name: 'Design Squad',
        logoUrl: null,
        initial: 'D',
        memberCount: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      TeamModel(
        id: '3',
        name: 'Dev Masters',
        logoUrl: null,
        initial: 'D',
        memberCount: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  @override
  Future<List<TeamEntity>> searchTeams(String query) async {
    // TODO: Implement actual search API call
    await Future.delayed(const Duration(milliseconds: 500));

    final allTeams = await getUserTeams();
    return allTeams
        .where((team) => team.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<void> createTeam(String name, String? logoUrl) async {
    // TODO: Implement actual create team API call
    await Future.delayed(const Duration(seconds: 1));
  }
}
