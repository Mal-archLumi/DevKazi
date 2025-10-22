// lib/features/auth/data/services/auth_service.dart
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class AuthService {
  final GoogleSignIn _googleSignIn;
  final FlutterSecureStorage _storage;
  final Logger _logger;
  final String _backendUrl;

  AuthService()
    : _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      ),
      _storage = const FlutterSecureStorage(),
      _logger = Logger(),
      _backendUrl = dotenv.env['BACKEND_URL'] ?? '';

  Future<Map<String, dynamic>> loginWithEmail(
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/v1/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      _logger.e('Login error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/v1/auth/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Sign up failed');
      }
    } catch (e) {
      _logger.e('Sign up error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw Exception('Sign in cancelled');
      }

      final auth = await account.authentication;
      if (auth.idToken == null) {
        throw Exception('Failed to obtain Google ID token');
      }

      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/v1/auth/google'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'idToken': auth.idToken}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Google sign in failed');
      }
    } catch (e) {
      _logger.e('Google sign in error: $e');
      rethrow;
    }
  }

  Future<void> storeTokens(String accessToken, String refreshToken) async {
    try {
      await _storage.write(key: 'access_token', value: accessToken);
      await _storage.write(key: 'refresh_token', value: refreshToken);
    } catch (e) {
      _logger.e('Error storing tokens: $e');
      rethrow;
    }
  }

  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
      await _storage.delete(key: 'email');
    } catch (e) {
      _logger.e('Error clearing tokens: $e');
      rethrow;
    }
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }
}
