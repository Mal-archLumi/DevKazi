import 'dart:developer';
import 'dart:math' hide log;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/services/token_refresh_service.dart';

class ApiResponse<T> {
  final T? data;
  final int statusCode;
  final String? message;

  ApiResponse({this.data, required this.statusCode, this.message});

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final TokenRefreshService _tokenService;
  final String baseUrl;

  // Track retry attempts
  final Map<String, int> _retryCounts = {};

  ApiClient({required this.baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      ),
      _secureStorage = const FlutterSecureStorage(),
      _tokenService = TokenRefreshService() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final path = options.path;
          log('🟡 ApiClient: Request to $path');

          // Check if request requires auth
          if (options.extra['requiresAuth'] == true) {
            try {
              // Get valid token (auto-refresh if needed)
              final token = await _tokenService.getValidAccessToken();

              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
                log(
                  '🟡 ApiClient: Added auth token (${token.substring(0, min(20, token.length))}...)',
                );
              } else {
                log('🔴 ApiClient: No valid access token available');
                // Don't add auth header if no token
              }
            } catch (e) {
              log('🔴 ApiClient: Error getting auth token: $e');
            }
          }

          // Reset retry count for this request
          _retryCounts[path] = 0;

          handler.next(options);
        },
        onError: (error, handler) async {
          final path = error.requestOptions.path;
          final statusCode = error.response?.statusCode;

          log('🔴 ApiClient: Error for $path - Status: $statusCode');

          // Handle 401 Unauthorized (token expired)
          if (statusCode == 401) {
            final retryCount = _retryCounts[path] ?? 0;

            if (retryCount < 2) {
              // Max 2 retries
              _retryCounts[path] = retryCount + 1;
              log(
                '🔄 ApiClient: Token expired, attempting refresh and retry...',
              );

              try {
                // Try to refresh the token
                final newToken = await _tokenService.refreshAccessToken();

                if (newToken != null) {
                  // Update the request with new token
                  error.requestOptions.headers['Authorization'] =
                      'Bearer $newToken';

                  // Create new request options
                  final opts = Options(
                    method: error.requestOptions.method,
                    headers: error.requestOptions.headers,
                  );

                  // Retry the request
                  log('🔄 ApiClient: Retrying request with new token...');
                  final response = await _dio.request(
                    error.requestOptions.path,
                    data: error.requestOptions.data,
                    queryParameters: error.requestOptions.queryParameters,
                    options: opts,
                  );

                  return handler.resolve(response);
                } else {
                  log('🔴 ApiClient: Token refresh failed, logging out...');
                  // Clear tokens and fail
                  await _secureStorage.delete(key: 'access_token');
                  await _secureStorage.delete(key: 'refresh_token');
                }
              } catch (refreshError) {
                log('🔴 ApiClient: Error during token refresh: $refreshError');
              }
            }
          }

          handler.next(error);
        },
        onResponse: (response, handler) {
          final path = response.requestOptions.path;
          log(
            '🟢 ApiClient: Response from $path - Status: ${response.statusCode}',
          );
          handler.next(response);
        },
      ),
    );
  }

  Future<ApiResponse<T>> _request<T>(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    Map<String, dynamic>? extraHeaders,
  }) async {
    try {
      log('🟡 ApiClient: $method $path, requiresAuth: $requiresAuth');

      final options = Options(
        extra: {'requiresAuth': requiresAuth},
        method: method,
      );

      // Add extra headers if provided
      if (extraHeaders != null) {
        options.headers ??= {};
        options.headers!.addAll(extraHeaders);
      }

      final Response response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      log(
        '🟢 ApiClient: $method $path - Success - Status: ${response.statusCode}',
      );

      return ApiResponse<T>(
        data: response.data,
        statusCode: response.statusCode!,
      );
    } on DioException catch (e) {
      log(
        '🔴 ApiClient: $method $path - DioError - Status: ${e.response?.statusCode}, Message: ${e.message}',
      );
      log('🔴 ApiClient: Response data: ${e.response?.data}');

      return ApiResponse<T>(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['message'] ?? e.message,
      );
    } catch (e, stackTrace) {
      log('🔴 ApiClient: $method $path - Unexpected error - $e');
      log('🔴 Stack trace: $stackTrace');
      return ApiResponse<T>(statusCode: 500, message: 'Network error occurred');
    }
  }

  // Existing methods remain the same...
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    Map<String, dynamic>? headers,
  }) async {
    return _request<T>(
      'GET',
      path,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
      extraHeaders: headers,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    bool requiresAuth = false,
    Map<String, dynamic>? headers,
  }) async {
    return _request<T>(
      'POST',
      path,
      data: data,
      requiresAuth: requiresAuth,
      extraHeaders: headers,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    bool requiresAuth = false,
    Map<String, dynamic>? headers,
  }) async {
    return _request<T>(
      'PUT',
      path,
      data: data,
      requiresAuth: requiresAuth,
      extraHeaders: headers,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    bool requiresAuth = false,
    Map<String, dynamic>? headers,
  }) async {
    return _request<T>(
      'DELETE',
      path,
      data: data,
      requiresAuth: requiresAuth,
      extraHeaders: headers,
    );
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    bool requiresAuth = false,
    Map<String, dynamic>? headers,
  }) async {
    return _request<T>(
      'PATCH',
      path,
      data: data,
      requiresAuth: requiresAuth,
      extraHeaders: headers,
    );
  }
}
