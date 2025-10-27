// data/datasources/remote/team_remote_data_source.dart
import 'dart:developer';
import '../../../domain/entities/team_entity.dart';
import '../../models/team_model.dart';
import '/../../core/errors/exceptions.dart';
import '/../../core/network/api_client.dart';

abstract class TeamRemoteDataSource {
  Future<List<TeamEntity>> getUserTeams();
  Future<List<TeamEntity>> searchTeams(String query);
  Future<void> createTeam(String name, String? description);
}

class TeamRemoteDataSourceImpl implements TeamRemoteDataSource {
  final ApiClient client;

  TeamRemoteDataSourceImpl({required this.client});

  @override
  Future<List<TeamEntity>> getUserTeams() async {
    try {
      final response = await client.get<List<dynamic>>(
        '/teams/my-teams',
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return response.data!
            .map(
              (teamJson) =>
                  TeamModel.fromJson(teamJson as Map<String, dynamic>),
            )
            .toList();
      } else {
        log(
          'Failed to load teams: ${response.statusCode} - ${response.message}',
        );
        throw ServerException(
          response.message ?? 'Failed to load teams: ${response.statusCode}',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      log('Network error in getUserTeams: $e');
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<List<TeamEntity>> searchTeams(String query) async {
    try {
      final response = await client.get<List<dynamic>>(
        '/teams/search',
        queryParameters: {'q': query},
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return response.data!
            .map(
              (teamJson) =>
                  TeamModel.fromJson(teamJson as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw ServerException(
          response.message ?? 'Failed to search teams: ${response.statusCode}',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      log('Network error in searchTeams: $e');
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<void> createTeam(String name, String? description) async {
    try {
      final response = await client.post(
        '/teams',
        data: {'name': name, 'description': description},
        requiresAuth: true,
      );

      if (!response.isSuccess) {
        throw ServerException(
          response.message ?? 'Failed to create team: ${response.statusCode}',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      log('Network error in createTeam: $e');
      throw ServerException('Network error: $e');
    }
  }
}
