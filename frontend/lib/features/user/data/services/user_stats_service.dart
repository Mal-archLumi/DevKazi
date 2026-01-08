// features/user/data/services/user_stats_service.dart

import 'package:frontend/core/network/api_client.dart';

class UserStatsService {
  final ApiClient client;

  UserStatsService({required this.client});

  Future<int> getUserTeamCount(String userId) async {
    try {
      final response = await client.get(
        '/users/profile/stats',
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return response.data!['teamCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error fetching team count: $e');
      return 0;
    }
  }

  Future<int> getUserProjectCount(String userId) async {
    try {
      final response = await client.get(
        '/users/profile/stats',
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return response.data!['projectCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error fetching project count: $e');
      return 0;
    }
  }

  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      final response = await client.get(
        '/users/profile/stats',
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return {
          'teamCount': response.data!['teamCount'] ?? 0,
          'projectCount': response.data!['projectCount'] ?? 0,
        };
      }
      return {'teamCount': 0, 'projectCount': 0};
    } catch (e) {
      print('Error fetching user stats: $e');
      return {'teamCount': 0, 'projectCount': 0};
    }
  }
}
