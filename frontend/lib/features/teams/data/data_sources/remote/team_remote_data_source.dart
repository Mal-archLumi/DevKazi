// data/datasources/remote/team_remote_data_source.dart
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/teams/domain/entities/join_request_entity.dart';

import '../../../domain/entities/team_entity.dart';
import '../../models/team_model.dart';
import '../../models/join_request_model.dart';
import '/../../core/errors/exceptions.dart';
import '/../../core/network/api_client.dart';

abstract class TeamRemoteDataSource {
  Future<List<TeamModel>> getUserTeams();
  Future<List<TeamModel>> searchTeams(String query);
  Future<TeamModel> createTeam({
    required String name,
    required String description,
    required List<String> skills,
    int? maxMembers,
  });
  Future<List<TeamModel>> getAllTeams();
  Future<bool> requestToJoinTeam(String teamId);
  Future<List<TeamModel>> searchBrowseTeams(String query);
  Future<TeamModel> getTeamById(String teamId);
  Future<void> leaveTeam(String teamId);

  // Join request methods
  Future<List<JoinRequestModel>> getJoinRequests(String teamId);
  Future<JoinRequestModel> handleJoinRequest({
    required String teamId,
    required String requestId,
    required bool approved,
    String? message,
  });
  Future<void> cancelJoinRequest(String requestId);
  Future<List<JoinRequestModel>> getMyPendingRequests();
  Future<JoinRequestEntity> approveOrRejectJoinRequest({
    required String requestId,
    required String action,
    String? message,
  });

  Future<void> joinTeam(String teamId) async {}
}

class TeamRemoteDataSourceImpl implements TeamRemoteDataSource {
  final ApiClient client;

  TeamRemoteDataSourceImpl({required this.client});

  @override
  Future<TeamModel> getTeamById(String teamId) async {
    try {
      log('🟡 TeamRemoteDataSource: Making API call to /teams/$teamId');

      final response = await client.get<Map<String, dynamic>>(
        '/teams/$teamId',
        requiresAuth: true,
      );

      log(
        '🟡 TeamRemoteDataSource: API Response - Status: ${response.statusCode}',
      );

      if (response.isSuccess && response.data != null) {
        log('🟢 TeamRemoteDataSource: Team data fetched successfully');

        final teamData = response.data!;
        log('🟢 TEAM WITH MEMBERS DATA: $teamData');

        final team = TeamModel.fromJson(teamData);
        return team;
      } else {
        log(
          '🔴 TeamRemoteDataSource: Failed to fetch team - Status: ${response.statusCode}',
        );
        throw ServerException(
          response.message ?? 'Failed to fetch team: ${response.statusCode}',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      log('🔴 TeamRemoteDataSource: Network error - $e');
      log('🔴 Stack trace: $stackTrace');
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<List<TeamModel>> getUserTeams() async {
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
  Future<List<TeamModel>> searchTeams(String query) async {
    try {
      log(
        '🟡 TeamRemoteDataSource: Making API call to /teams/search/my-teams with query: "$query"',
      );

      final response = await client.get<List<dynamic>>(
        '/teams/search/my-teams', // FIXED ENDPOINT
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
  Future<List<TeamModel>> searchBrowseTeams(String query) async {
    try {
      log(
        '🟡 TeamRemoteDataSource: Making API call to /teams/search/browse with query: "$query"',
      );

      final response = await client.get<List<dynamic>>(
        '/teams/search/browse',
        queryParameters: {'q': query},
        requiresAuth: true,
      );

      log(
        '🟡 TeamRemoteDataSource: API Response - Status: ${response.statusCode}',
      );
      log('🟡 TeamRemoteDataSource: Response data: ${response.data}');

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

        // Log each team name for debugging
        log('🟢 TeamRemoteDataSource: SEARCH RESULTS FOR "$query":');
        for (var i = 0; i < teams.length; i++) {
          final team = teams[i];
          log(
            '🟢 TeamRemoteDataSource: [$i] Team: "${team.name}" | Description: "${team.description ?? "No description"}"',
          );
        }

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
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      log('🔴 TeamRemoteDataSource: Network error - $e');
      log('🔴 Stack trace: $stackTrace');
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<TeamModel> createTeam({
    required String name,
    required String description,
    required List<String> skills,
    int? maxMembers,
  }) async {
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
  Future<List<TeamModel>> getAllTeams() async {
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

  @override
  Future<void> leaveTeam(String teamId) async {
    try {
      log('🟡 TeamRemoteDataSource: Leaving team - teamId: $teamId');

      final response = await client.delete(
        '/teams/leave/$teamId',
        requiresAuth: true,
      );

      log(
        '🟡 TeamRemoteDataSource: Leave team response - Status: ${response.statusCode}',
      );
      log(
        '🟡 TeamRemoteDataSource: Leave team response - Message: ${response.message}',
      );
      log(
        '🟡 TeamRemoteDataSource: Leave team response - Data: ${response.data}',
      );

      if (response.isSuccess) {
        log('🟢 TeamRemoteDataSource: Team left successfully');
      } else {
        log(
          '🔴 TeamRemoteDataSource: Failed to leave team - Status: ${response.statusCode}, Message: ${response.message}',
        );
        throw ServerException(
          response.message ?? 'Failed to leave team: ${response.statusCode}',
        );
      }
    } on ServerException catch (e) {
      log(
        '🔴 TeamRemoteDataSource: ServerException in leaveTeam - ${e.message}',
      );
    } catch (e, stackTrace) {
      log('🔴 TeamRemoteDataSource: Leave team network error - $e');
      log('🔴 Stack trace: $stackTrace');
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<bool> requestToJoinTeam(String teamId) async {
    try {
      log('🟡 TeamRemoteDataSource: Requesting to join team - teamId: $teamId');

      // FIX: Use correct endpoint - POST /join-requests with body containing teamId
      final response = await client.post(
        '/join-requests', // Changed from '/teams/request-join/$teamId'
        data: {
          'teamId': teamId, // Send teamId in request body
        },
        requiresAuth: true,
      );

      log(
        '🟡 TeamRemoteDataSource: Request to join team response - Status: ${response.statusCode}',
      );

      if (response.isSuccess) {
        log('🟢 TeamRemoteDataSource: Join request sent successfully');
        return true;
      } else {
        log(
          '🔴 TeamRemoteDataSource: Failed to send join request - Status: ${response.statusCode}, Message: ${response.message}',
        );
        throw ServerException(
          response.message ??
              'Failed to request to join team: ${response.statusCode}',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      log('🔴 TeamRemoteDataSource: Request to join team network error - $e');
      log('🔴 Stack trace: $stackTrace');
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<List<JoinRequestModel>> getJoinRequests(String teamId) async {
    try {
      final response = await client.get('/join-requests/team/$teamId');

      if (response is List) {
        return response
            .map(
              (json) => JoinRequestModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('🔴 TeamRemoteDataSource: Error getting join requests: $e');
      rethrow;
    }
  }

  @override
  Future<JoinRequestModel> handleJoinRequest({
    required String teamId,
    required String requestId,
    required bool approved,
    String? message,
  }) async {
    try {
      final response = await client.put(
        '/join-requests/$requestId/team/$teamId',
        data: {'approved': approved, if (message != null) 'message': message},
      );

      return JoinRequestModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      debugPrint('🔴 TeamRemoteDataSource: Error handling join request: $e');
      rethrow;
    }
  }

  @override
  Future<void> cancelJoinRequest(String requestId) async {
    try {
      await client.delete('/join-requests/$requestId');
    } catch (e) {
      debugPrint('🔴 TeamRemoteDataSource: Error cancelling join request: $e');
      rethrow;
    }
  }

  @override
  Future<List<JoinRequestModel>> getMyPendingRequests() async {
    try {
      final response = await client.get('/join-requests/my-requests');

      if (response is List) {
        return response
            .map(
              (json) => JoinRequestModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint(
        '🔴 TeamRemoteDataSource: Error getting my pending requests: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<JoinRequestModel>> getTeamJoinRequests(String teamId) async {
    try {
      log('🟡 TeamRemoteDataSource: Fetching join requests for team: $teamId');

      final response = await client.get(
        '/join-requests/team/$teamId',
        requiresAuth: true,
      );

      log(
        '🟡 TeamRemoteDataSource: Join requests response - Status: ${response.statusCode}',
      );

      if (response.isSuccess && response.data != null) {
        final List<dynamic> requestsList = response.data is List
            ? response.data
            : (response.data['data'] ?? []);

        final requests = requestsList
            .map(
              (json) => JoinRequestModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        log('🟢 TeamRemoteDataSource: Found ${requests.length} join requests');
        return requests;
      } else {
        throw ServerException(
          response.message ?? 'Failed to fetch join requests',
        );
      }
    } catch (e) {
      log('🔴 TeamRemoteDataSource: Error fetching join requests - $e');
      rethrow;
    }
  }

  @override
  Future<JoinRequestEntity> approveOrRejectJoinRequest({
    required String requestId,
    required String action,
    String? message,
  }) async {
    try {
      log(
        '🟡 TeamRemoteDataSource: $action join request - requestId: $requestId',
      );

      final response = await client.put(
        '/join-requests/$requestId/$action',
        data: {if (message != null) 'message': message},
        requiresAuth: true,
      );

      log(
        '🟡 TeamRemoteDataSource: $action join request response - Status: ${response.statusCode}',
      );

      if (response.isSuccess && response.data != null) {
        log('🟢 TeamRemoteDataSource: Join request ${action}d successfully');
        return JoinRequestModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          response.message ?? 'Failed to $action join request',
        );
      }
    } catch (e) {
      log('🔴 TeamRemoteDataSource: Error ${action}ing join request - $e');
      rethrow;
    }
  }
}
