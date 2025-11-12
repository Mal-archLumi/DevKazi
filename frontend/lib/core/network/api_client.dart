import 'dart:developer';
import 'dart:math' hide log;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  final String baseUrl;

  ApiClient({required this.baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      ),
      _secureStorage = const FlutterSecureStorage() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if required
          if (options.extra['requiresAuth'] == true) {
            final token = await _secureStorage.read(key: 'access_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle specific error cases
          if (error.response?.statusCode == 401) {
            // Token expired, logout user
            await _secureStorage.delete(key: 'access_token');
          }
          handler.next(error);
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
  }) async {
    try {
      log('🟡 ApiClient: $method $path, requiresAuth: $requiresAuth');

      final options = Options(
        extra: {'requiresAuth': requiresAuth},
        method: method,
      );

      if (requiresAuth) {
        final token = await _secureStorage.read(key: 'access_token');
        log('🟡 ApiClient: Auth required, token exists: ${token != null}');
        if (token != null) {
          log(
            '🟡 ApiClient: Sending token: ${token.substring(0, min(20, token.length))}...',
          );
          options.headers = {'Authorization': 'Bearer $token'};
        } else {
          log('🔴 ApiClient: No token found for authenticated request!');
        }
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
      log('🔴 ApiClient: Headers sent: ${e.requestOptions.headers}');
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

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
  }) async {
    return _request<T>(
      'GET',
      path,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    bool requiresAuth = false,
  }) async {
    return _request<T>('POST', path, data: data, requiresAuth: requiresAuth);
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    bool requiresAuth = false,
  }) async {
    return _request<T>('PUT', path, data: data, requiresAuth: requiresAuth);
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    bool requiresAuth = false,
  }) async {
    return _request<T>('DELETE', path, data: data, requiresAuth: requiresAuth);
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    bool requiresAuth = false,
  }) async {
    return _request<T>('PATCH', path, data: data, requiresAuth: requiresAuth);
  }
}
