import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class TokenRefreshService {
  final FlutterSecureStorage _storage;
  final Logger _logger;
  final String _backendUrl;
  bool _isRefreshing = false;
  String? _refreshPromise;

  static final TokenRefreshService _instance = TokenRefreshService._internal();

  factory TokenRefreshService() {
    return _instance;
  }

  TokenRefreshService._internal()
    : _storage = const FlutterSecureStorage(),
      _logger = Logger(),
      _backendUrl = dotenv.env['BACKEND_URL'] ?? '';

  Future<String?> refreshAccessToken() async {
    // Prevent multiple simultaneous refresh requests
    if (_isRefreshing && _refreshPromise != null) {
      _logger.d('Waiting for existing refresh promise...');
      return _refreshPromise;
    }

    try {
      _isRefreshing = true;

      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) {
        _logger.e('No refresh token available');
        _isRefreshing = false;
        return null;
      }

      _logger.d('Refreshing access token...');

      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/v1/auth/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];

        if (newAccessToken == null || newAccessToken.isEmpty) {
          throw Exception('Invalid response: No access token received');
        }

        // Store new tokens
        await _storage.write(key: 'access_token', value: newAccessToken);

        // Update refresh token if provided
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await _storage.write(key: 'refresh_token', value: newRefreshToken);
        }

        _logger.d('Access token refreshed successfully');

        // Create a promise that resolves to the new token
        _refreshPromise = newAccessToken;
        return newAccessToken;
      } else {
        final error = jsonDecode(response.body);
        _logger.e('Token refresh failed: ${error['message']}');

        // Clear tokens if refresh fails
        if (response.statusCode == 401) {
          await _storage.delete(key: 'access_token');
          await _storage.delete(key: 'refresh_token');
        }

        return null;
      }
    } catch (e) {
      _logger.e('Error refreshing token: $e');
      return null;
    } finally {
      _isRefreshing = false;
      Future.delayed(const Duration(seconds: 2), () {
        _refreshPromise = null;
      });
    }
  }

  Future<bool> isTokenExpired(String token) async {
    try {
      // Decode the JWT to check expiration
      final parts = token.split('.');
      if (parts.length != 3) {
        return true;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(decoded);

      final exp = payloadMap['exp'];
      if (exp == null) {
        return true;
      }

      final expiryTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      final bufferTime = const Duration(
        minutes: 5,
      ); // Refresh 5 minutes before expiry

      return now.isAfter(expiryTime.subtract(bufferTime));
    } catch (e) {
      _logger.e('Error checking token expiry: $e');
      return true;
    }
  }

  Future<String?> getValidAccessToken() async {
    final accessToken = await _storage.read(key: 'access_token');

    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    // Check if token is expired or about to expire
    final expired = await isTokenExpired(accessToken);

    if (expired) {
      return await refreshAccessToken();
    }

    return accessToken;
  }
}
