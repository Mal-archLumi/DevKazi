import 'dart:convert';
// ignore: unused_import
import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/entities/tokens_entity.dart'; // Added import for TokensEntity
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userDataKey =
      'user_data'; // Added for comprehensive cleanup

  final FlutterSecureStorage _secureStorage;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({required FlutterSecureStorage secureStorage})
    : _secureStorage = const FlutterSecureStorage(),
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      );

  // Helper method for logging auth errors
  void _logAuthError(String method, dynamic error, [http.Response? response]) {
    print('🔴 AUTH ERROR in $method:');
    print('   Error: $error');
    if (response != null) {
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');
    }
  }

  void _logAuthSuccess(String method, [String? additionalInfo]) {
    print('🟢 AUTH SUCCESS in $method');
    if (additionalInfo != null) {
      print('   Info: $additionalInfo');
    }
  }

  void _logAuthResponse(String method, http.Response response) {
    print('🟡 AUTH RESPONSE in $method:');
    print('   Status: ${response.statusCode}');
    print('   Body: ${response.body}');
  }

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      print('🟡 Attempting login for: $email');

      final response = await http
          .post(
            Uri.parse('${dotenv.env['BACKEND_URL']}/api/v1/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      _logAuthResponse('login', response);

      // FIX: Check for both 200 and 201 status codes (your API returns 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // FIX: Properly extract user data from the nested structure
        final userData = data['user'] ?? data;

        final user = UserEntity(
          id: userData['_id'] ?? userData['id'] ?? 'unknown_id',
          email: userData['email'] ?? email,
          name: userData['name'] ?? 'User',
          createdAt: _parseDateTime(userData['createdAt']),
          updatedAt: _parseDateTime(userData['updatedAt']),
          accessToken: data['access_token'] ?? '',
          refreshToken: data['refresh_token'] ?? '',
        );

        // Validate that we have required tokens
        if (user.accessToken.isEmpty || user.refreshToken.isEmpty) {
          _logAuthError('login', 'Authentication failed: Missing tokens');
          return Left(ServerFailure('Authentication failed: Missing tokens'));
        }

        await saveTokens(user.accessToken, user.refreshToken);
        await _saveUserId(user.id);

        _logAuthSuccess('login', 'User ${user.email} logged in successfully');
        return Right(user);
      } else {
        final errorData = jsonDecode(response.body);
        _logAuthError('login', 'API error: $errorData');
        return Left(ServerFailure(errorData['message'] ?? 'Login failed'));
      }
    } catch (e) {
      _logAuthError('login', e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      print('🟡 Attempting signup for: $email, name: $name');

      final response = await http
          .post(
            Uri.parse('${dotenv.env['BACKEND_URL']}/api/v1/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      _logAuthResponse('signUp', response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // FIX: Properly extract user data from response
        final userData = data['user'] ?? data;

        final user = UserEntity(
          id: userData['_id'] ?? userData['id'] ?? 'unknown_id',
          email: userData['email'] ?? email,
          name: userData['name'] ?? name,
          createdAt: _parseDateTime(userData['createdAt']),
          updatedAt: _parseDateTime(userData['updatedAt']),
          accessToken: data['access_token'] ?? '',
          refreshToken: data['refresh_token'] ?? '',
        );

        // Validate that we have required tokens
        if (user.accessToken.isEmpty || user.refreshToken.isEmpty) {
          _logAuthError('signUp', 'Authentication failed: Missing tokens');
          return Left(ServerFailure('Authentication failed: Missing tokens'));
        }

        await saveTokens(user.accessToken, user.refreshToken);
        await _saveUserId(user.id);

        _logAuthSuccess('signUp', 'User ${user.email} signed up successfully');
        return Right(user);
      } else {
        final errorData = jsonDecode(response.body);
        _logAuthError('signUp', 'API error: $errorData');
        return Left(ServerFailure(errorData['message'] ?? 'Sign up failed'));
      }
    } catch (e) {
      _logAuthError('signUp', e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithGoogle(String idToken) async {
    try {
      print('🟡 Attempting Google signup with ID token');

      final response = await http
          .post(
            Uri.parse('${dotenv.env['BACKEND_URL']}/api/v1/auth/google'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'idToken': idToken}),
          )
          .timeout(const Duration(seconds: 30));

      _logAuthResponse('signUpWithGoogle', response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // FIX: Properly extract user data from response
        final userData = data['user'] ?? data;

        final user = UserEntity(
          id: userData['_id'] ?? userData['id'] ?? 'unknown_id',
          email: userData['email'] ?? '',
          name: userData['name'] ?? 'Google User',
          createdAt: _parseDateTime(userData['createdAt']),
          updatedAt: _parseDateTime(userData['updatedAt']),
          accessToken: data['access_token'] ?? '',
          refreshToken: data['refresh_token'] ?? '',
        );

        // Validate that we have required tokens
        if (user.accessToken.isEmpty || user.refreshToken.isEmpty) {
          _logAuthError(
            'signUpWithGoogle',
            'Authentication failed: Missing tokens',
          );
          return Left(ServerFailure('Authentication failed: Missing tokens'));
        }

        await saveTokens(user.accessToken, user.refreshToken);
        await _saveUserId(user.id);

        _logAuthSuccess(
          'signUpWithGoogle',
          'Google user ${user.email} signed up successfully',
        );
        return Right(user);
      } else {
        final errorData = jsonDecode(response.body);
        _logAuthError('signUpWithGoogle', 'API error: $errorData');
        return Left(
          ServerFailure(errorData['message'] ?? 'Google sign up failed'),
        );
      }
    } catch (e) {
      _logAuthError('signUpWithGoogle', e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle() async {
    try {
      print('🟡 Starting Google Sign-In flow...');

      // Debug: Check what client ID we're using
      print('🟡 Using Google Client ID: ${dotenv.env['GOOGLE_WEB_CLIENT_ID']}');

      final account = await _googleSignIn.signIn();
      if (account == null) {
        print('🔴 Google sign-in cancelled by user');
        return Left(ServerFailure('Google sign-in cancelled'));
      }

      print('🟡 Google account selected: ${account.email}');
      print('🟡 Account details: ${account.displayName}, ${account.id}');

      final auth = await account.authentication;
      print(
        '🟡 Google auth obtained - ID Token: ${auth.idToken != null ? "PRESENT" : "MISSING"}',
      );
      print(
        '🟡 Access Token: ${auth.accessToken != null ? "PRESENT" : "MISSING"}',
      );

      if (auth.idToken == null) {
        _logAuthError('loginWithGoogle', 'Failed to obtain Google ID token');
        return Left(ServerFailure('Failed to obtain Google ID token'));
      }

      print('🟡 Google ID token obtained, proceeding to backend...');
      final idTokenLength = auth.idToken!.length;
      final previewLength = idTokenLength < 50 ? idTokenLength : 50;
      print(
        '🟡 ID Token first $previewLength chars: ${auth.idToken!.substring(0, previewLength)}...',
      );

      // Use the existing signUpWithGoogle method
      return await signUpWithGoogle(auth.idToken!);
    } catch (e) {
      print('🔴 Google Sign-In Exception: $e');
      print('🔴 Exception type: ${e.runtimeType}');
      _logAuthError('loginWithGoogle', e);
      return Left(ServerFailure('Google sign-in failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      print('🟡 Logging out user...');

      // Sign out from Google if user was signed in with Google
      await _googleSignIn.signOut();

      // Clear all authentication-related data from secure storage
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _userDataKey);

      // Verify all data has been cleared
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      final userId = await _secureStorage.read(key: _userIdKey);

      if (accessToken == null && refreshToken == null && userId == null) {
        _logAuthSuccess('logout', 'All user data cleared successfully');
      } else {
        _logAuthError(
          'logout',
          'Some user data may not have been cleared properly',
        );
        // Continue anyway - don't fail the logout process
      }

      return const Right(null);
    } catch (e) {
      _logAuthError('logout', e);
      // Even if there's an error, we should still return success
      // to allow the user to proceed with logout
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      print('🟡 Fetching current user...');

      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      final userId = await _secureStorage.read(key: _userIdKey);

      if (accessToken == null || refreshToken == null || userId == null) {
        print('🔴 No user logged in - missing tokens');
        return Left(CacheFailure('No user logged in'));
      }

      // Make API call to get actual user details
      final response = await http
          .get(
            Uri.parse('${dotenv.env['BACKEND_URL']}/api/v1/auth/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 30));

      _logAuthResponse('getCurrentUser', response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserEntity(
          id: data['_id'] ?? data['id'] ?? userId,
          email: data['email'] ?? '',
          name: data['name'] ?? '',
          createdAt: _parseDateTime(data['createdAt']),
          updatedAt: _parseDateTime(data['updatedAt']),
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        _logAuthSuccess(
          'getCurrentUser',
          'User ${user.email} fetched successfully',
        );
        return Right(user);
      } else {
        _logAuthError('getCurrentUser', 'Failed to fetch user details');
        return Left(ServerFailure('Failed to fetch user details'));
      }
    } catch (e) {
      _logAuthError('getCurrentUser', e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(UserEntity user) async {
    try {
      print('🟡 Updating user profile for: ${user.email}');
      await _saveUserId(user.id);

      _logAuthSuccess('updateUserProfile');
      return const Right(null);
    } catch (e) {
      _logAuthError('updateUserProfile', e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    print('🟡 AuthRepositoryImpl: Saving tokens...');
    print('🟡 Access Token: ${accessToken.substring(0, 20)}...');
    print('🟡 Refresh Token: ${refreshToken.substring(0, 20)}...');

    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);

    // Verify tokens were saved
    final savedAccessToken = await _secureStorage.read(key: _accessTokenKey);
    final savedRefreshToken = await _secureStorage.read(key: _refreshTokenKey);

    print('🟢 AuthRepositoryImpl: Tokens saved successfully');
    print('🟢 Saved Access Token exists: ${savedAccessToken != null}');
    print('🟢 Saved Refresh Token exists: ${savedRefreshToken != null}');
  }

  Future<void> _saveUserId(String userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
    print('🟢 User ID saved: $userId');
  }

  @override
  Future<String?> getAccessToken() async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    print(
      '🟡 AuthRepositoryImpl: Retrieved access token - exists: ${token != null}',
    );
    if (token != null) {
      print(
        '🟡 Token preview: ${token.substring(0, min(20, token.length))}...',
      );
    }
    return token;
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  @override
  Future<TokensEntity> getTokens() async {
    final accessToken = await getAccessToken() ?? '';
    final refreshToken = await getRefreshToken() ?? '';
    return TokensEntity(accessToken: accessToken, refreshToken: refreshToken);
  }

  // Helper method to parse DateTime from string
  DateTime _parseDateTime(dynamic dateString) {
    try {
      if (dateString == null) return DateTime.now();
      if (dateString is String) {
        return DateTime.parse(dateString);
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  // Added method to check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final isLoggedIn = accessToken != null && accessToken.isNotEmpty;
      print('🟡 AuthRepositoryImpl: isLoggedIn = $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      print('🔴 AuthRepositoryImpl: Error checking login status: $e');
      return false;
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      print('🟡 AuthRepositoryImpl: Clearing tokens...');

      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _userDataKey);

      // Verify tokens were cleared
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);

      print('🟢 AuthRepositoryImpl: Tokens cleared successfully');
      print('🟢 Access token still exists: ${accessToken != null}');
      print('🟢 Refresh token still exists: ${refreshToken != null}');
    } catch (e) {
      print('🔴 AuthRepositoryImpl: Error clearing tokens: $e');
      rethrow;
    }
  }
}
