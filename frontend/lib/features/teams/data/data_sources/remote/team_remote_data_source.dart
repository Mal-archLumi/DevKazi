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
  Future<TeamEntity> createTeam(
    String name,
    String? description,
  ); // CHANGED: Return TeamEntity
  Future<List<TeamEntity>> getAllTeams();
  Future<void> joinTeam(String teamId);
  Future<List<TeamEntity>> getBrowseTeams();
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
    // CHANGED: Return TeamEntity
    try {
      log(
        '🟡 TeamRemoteDataSource: Creating team - name: $name, description: $description',
      );

      final response = await client.post(
        '/teams',
        data: {'name': name, 'description': description},
        requiresAuth: true,
      );

      log(
        '🟡 TeamRemoteDataSource: Create team response - Status: ${response.statusCode}',
      );

      if (response.isSuccess && response.data != null) {
        log('🟢 TeamRemoteDataSource: Team created successfully');
        // Parse and return the created team
        final teamData = response.data as Map<String, dynamic>;
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
        // FIXED: Backend returns array directly
        final List<dynamic> data = response.data!;
        log(
          'TeamRemoteDataSource: API call successful, parsing ${data.length} teams',
        );

        final teams = data
            .map((json) => TeamModel.fromJson(json as Map<String, dynamic>))
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

  @override
  Future<void> joinTeam(String teamId) async {
    try {
      log('🟡 TeamRemoteDataSource: Joining team - teamId: $teamId');

      final response = await client.post(
        '/teams/$teamId/join',
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
  Future<List<TeamEntity>> getBrowseTeams() async {
    try {
      print(
        '🟡 TeamRemoteDataSource: Using WORKING /teams/my-teams endpoint for browse teams...',
      );

      // Use the WORKING /teams/my-teams endpoint
      final response = await client.get<List<dynamic>>(
        '/teams/my-teams',
        requiresAuth: true,
      );

      print('🟢 TeamRemoteDataSource: Response status: ${response.statusCode}');

      if (response.isSuccess && response.data != null) {
        final List<dynamic> data = response.data!;
        print(
          '🟢 TeamRemoteDataSource: Found ${data.length} user teams from /teams/my-teams',
        );

        // Get ALL teams from a different source - for now return empty
        // We'll filter user teams on the frontend from getAllTeams
        final teams = data
            .map(
              (teamJson) =>
                  TeamModel.fromJson(teamJson as Map<String, dynamic>),
            )
            .toList();

        print(
          '🟢 TeamRemoteDataSource: Successfully parsed ${teams.length} user teams',
        );
        return teams;
      } else {
        print(
          '🔴 TeamRemoteDataSource: API call failed - Status: ${response.statusCode}',
        );
        throw ServerException(
          'Failed to load user teams: ${response.statusCode}',
        );
      }
    } on ServerException catch (e) {
      print('🔴 TeamRemoteDataSource: ServerException - ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      print('🔴 TeamRemoteDataSource: Network error - $e');
      print('🔴 Stack trace: $stackTrace');
      throw ServerException('Network error: $e');
    }
  }
}
