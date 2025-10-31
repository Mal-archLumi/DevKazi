// data/datasources/remote/team_remote_data_source.dart
import 'dart:developer';
import 'package:dio/dio.dart';

import '../../../domain/entities/team_entity.dart';
import '../../models/team_model.dart';
import '/../../core/errors/exceptions.dart';
import '/../../core/network/api_client.dart';

abstract class TeamRemoteDataSource {
  Future<List<TeamEntity>> getUserTeams();
  Future<List<TeamEntity>> searchTeams(String query);
  Future<TeamEntity> createTeam(String name, String? description);
  Future<List<TeamEntity>> getAllTeams();
  Future<void> joinTeam(String teamId);
}

class TeamRemoteDataSourceImpl implements TeamRemoteDataSource {
  final ApiClient client;

  TeamRemoteDataSourceImpl({required this.client});

  @override
  Future<List<TeamEntity>> getUserTeams() async {
    try {
      log('🟡 TeamRemoteDataSource: Making API call to /teams/my-teams');

      final response = await client.get<List<dynamic>>(
        '/teams/my-teams',
        requiresAuth: true,
      );

      log(
        '🟡 TeamRemoteDataSource: API Response - Status: ${response.statusCode}',
      );

      if (response.isSuccess && response.data != null) {
        log(
          '🟢 TeamRemoteDataSource: API call successful, parsing ${response.data!.length} teams',
        );

        // DEBUG: Print first team to see structure
        if (response.data!.isNotEmpty) {
          log('🟢 FIRST TEAM DATA: ${response.data!.first}');
        }

        final teams = response.data!
            .map(
              (teamJson) =>
                  TeamModel.fromJson(teamJson as Map<String, dynamic>),
            )
            .toList();

        log(
          '🟢 TeamRemoteDataSource: Successfully parsed ${teams.length} teams',
        );
        return teams;
      } else {
        log(
          '🔴 TeamRemoteDataSource: API call failed - Status: ${response.statusCode}, Message: ${response.message}',
        );
        throw ServerException(
          response.message ?? 'Failed to load teams: ${response.statusCode}',
        );
      }
    } on ServerException catch (e) {
      log('🔴 TeamRemoteDataSource: ServerException rethrown - ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      log('🔴 TeamRemoteDataSource: Network error - $e');
      log('🔴 Stack trace: $stackTrace');
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<List<TeamEntity>> searchTeams(String query) async {
    try {
      log(
        '🟡 TeamRemoteDataSource: Making API call to /teams/search with query: $query',
      );

      final response = await client.get<List<dynamic>>(
        '/teams/search',
        queryParameters: {'q': query},
        requiresAuth: true,
      );

      log(
        '🟡 TeamRemoteDataSource: API Response - Status: ${response.statusCode}',
      );

      if (response.isSuccess && response.data != null) {
        log(
          '🟢 TeamRemoteDataSource: API call successful, parsing ${response.data!.length} teams',
        );

        final teams = response.data!
            .map(
              (teamJson) =>
                  TeamModel.fromJson(teamJson as Map<String, dynamic>),
            )
            .toList();

        log(
          '🟢 TeamRemoteDataSource: Successfully parsed ${teams.length} teams',
        );
        return teams;
      } else {
        log(
          '🔴 TeamRemoteDataSource: API call failed - Status: ${response.statusCode}, Message: ${response.message}',
        );
        throw ServerException(
          response.message ?? 'Failed to search teams: ${response.statusCode}',
        );
      }
    } on ServerException catch (e) {
      log('🔴 TeamRemoteDataSource: ServerException rethrown - ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      log('🔴 TeamRemoteDataSource: Network error - $e');
      log('🔴 Stack trace: $stackTrace');
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<TeamEntity> createTeam(String name, String? description) async {
    try {
      log(
        '🟡 TeamRemoteDataSource: Creating team - name: $name, description: $description',
      );

      final response = await client.post(
        '/teams',
        data: {
          'name': name,
          'description': description ?? '', // Backend expects description
        },
        requiresAuth: true,
      );

      log(
        '🟡 TeamRemoteDataSource: Create team response - Status: ${response.statusCode}',
      );

      if (response.isSuccess && response.data != null) {
        log('🟢 TeamRemoteDataSource: Team created successfully');
        // Parse and return the created team
        final teamData = response.data as Map<String, dynamic>;
        log('🟢 CREATED TEAM DATA: $teamData');
        final team = TeamModel.fromJson(teamData);
        return team;
      } else {
        log(
          '🔴 TeamRemoteDataSource: Failed to create team - Status: ${response.statusCode}, Message: ${response.message}',
        );
        throw ServerException(
          response.message ?? 'Failed to create team: ${response.statusCode}',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      log('🔴 TeamRemoteDataSource: Create team network error - $e');
      log('🔴 Stack trace: $stackTrace');
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<void> joinTeam(String teamId) async {
    try {
      log('🟡 TeamRemoteDataSource: Joining team - teamId: $teamId');

      final response = await client.post(
        '/teams/join/$teamId',
        requiresAuth: true,
      );

      log(
        '🟡 TeamRemoteDataSource: Join team response - Status: ${response.statusCode}',
      );

      if (response.isSuccess) {
        log('🟢 TeamRemoteDataSource: Team joined successfully');
      } else {
        log(
          '🔴 TeamRemoteDataSource: Failed to join team - Status: ${response.statusCode}, Message: ${response.message}',
        );
        throw ServerException(
          response.message ?? 'Failed to join team: ${response.statusCode}',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      log('🔴 TeamRemoteDataSource: Join team network error - $e');
      log('🔴 Stack trace: $stackTrace');
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<List<TeamEntity>> getAllTeams() async {
    try {
      log('TeamRemoteDataSource: Making API call to /teams');

      final response = await client.get<List<dynamic>>(
        '/teams',
        requiresAuth: true,
      );

      log(
        'TeamRemoteDataSource: API Response - Status: ${response.statusCode}',
      );

      if (response.isSuccess && response.data != null) {
        log(
          '🟢 TeamRemoteDataSource: API call successful, parsing ${response.data!.length} teams',
        );

        final teams = response.data!
            .map(
              (teamJson) =>
                  TeamModel.fromJson(teamJson as Map<String, dynamic>),
            )
            .toList();

        log('TeamRemoteDataSource: Successfully parsed ${teams.length} teams');
        return teams;
      } else {
        log(
          'TeamRemoteDataSource: API call failed - Status: ${response.statusCode}',
        );
        throw ServerException(
          response.message ?? 'Failed to load teams: ${response.statusCode}',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      log('Network error: $e\n$stackTrace');
      throw ServerException('Network error: $e');
    }
  }
}
