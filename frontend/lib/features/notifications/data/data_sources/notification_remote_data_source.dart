// lib/features/notifications/data/data_sources/notification_remote_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/notifications/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({int limit = 50});
  Future<int> getUnreadCount();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<void> clearAll();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final String baseUrl;
  final Future<String?> Function() getToken; // Changed to Future<String?>

  NotificationRemoteDataSourceImpl({
    required this.baseUrl,
    required this.getToken,
  });

  @override
  Future<List<NotificationModel>> getNotifications({int limit = 50}) async {
    final token = await getToken(); // Added await
    if (token == null) {
      throw AuthenticationFailure('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/notifications?limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw AuthenticationFailure('Please login again');
    } else {
      throw ServerFailure(
        'Failed to load notifications: ${response.statusCode}',
      );
    }
  }

  @override
  Future<int> getUnreadCount() async {
    final token = await getToken(); // Added await
    if (token == null) {
      throw AuthenticationFailure('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/notifications/unread-count'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['count'] ?? 0;
    } else if (response.statusCode == 401) {
      throw AuthenticationFailure('Please login again');
    } else {
      throw ServerFailure('Failed to get unread count: ${response.statusCode}');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final token = await getToken(); // Added await
    if (token == null) {
      throw AuthenticationFailure('No authentication token found');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/notifications/$notificationId/read'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw ServerFailure('Notification not found');
    } else if (response.statusCode == 401) {
      throw AuthenticationFailure('Please login again');
    } else {
      throw ServerFailure('Failed to mark as read: ${response.statusCode}');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final token = await getToken(); // Added await
    if (token == null) {
      throw AuthenticationFailure('No authentication token found');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/notifications/read-all'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw AuthenticationFailure('Please login again');
    } else {
      throw ServerFailure('Failed to mark all as read: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final token = await getToken(); // Added await
    if (token == null) {
      throw AuthenticationFailure('No authentication token found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/api/v1/notifications/$notificationId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw ServerFailure('Notification not found');
    } else if (response.statusCode == 401) {
      throw AuthenticationFailure('Please login again');
    } else {
      throw ServerFailure(
        'Failed to delete notification: ${response.statusCode}',
      );
    }
  }

  @override
  Future<void> clearAll() async {
    final token = await getToken(); // Added await
    if (token == null) {
      throw AuthenticationFailure('No authentication token found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/api/v1/notifications'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw AuthenticationFailure('Please login again');
    } else {
      throw ServerFailure(
        'Failed to clear notifications: ${response.statusCode}',
      );
    }
  }
}
