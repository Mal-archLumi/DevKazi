// core/network/api_client.dart
import 'dart:developer';
import 'dart:io';
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

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
  }) async {
    try {
      log('🟡 ApiClient: GET $path, requiresAuth: $requiresAuth');

      final options = Options(extra: {'requiresAuth': requiresAuth});

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

      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      log('🟢 ApiClient: GET $path - Success - Status: ${response.statusCode}');
      return ApiResponse<T>(
        data: response.data,
        statusCode: response.statusCode!,
      );
    } on DioException catch (e) {
      log(
        '🔴 ApiClient: GET $path - DioError - Status: ${e.response?.statusCode}, Message: ${e.message}',
      );
      log('🔴 ApiClient: Headers sent: ${e.requestOptions.headers}');
      log('🔴 ApiClient: Response data: ${e.response?.data}');

      return ApiResponse<T>(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['message'] ?? e.message,
      );
    } catch (e, stackTrace) {
      log('🔴 ApiClient: GET $path - Unexpected error - $e');
      log('🔴 Stack trace: $stackTrace');
      return ApiResponse<T>(statusCode: 500, message: 'Network error occurred');
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    bool requiresAuth = false,
  }) async {
    try {
      log('🟡 ApiClient: POST $path, requiresAuth: $requiresAuth');

      final options = Options(extra: {'requiresAuth': requiresAuth});

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

      final response = await _dio.post(path, data: data, options: options);

      log(
        '🟢 ApiClient: POST $path - Success - Status: ${response.statusCode}',
      );
      return ApiResponse<T>(
        data: response.data,
        statusCode: response.statusCode!,
      );
    } on DioException catch (e) {
      log(
        '🔴 ApiClient: POST $path - DioError - Status: ${e.response?.statusCode}, Message: ${e.message}',
      );
      log('🔴 ApiClient: Headers sent: ${e.requestOptions.headers}');
      log('🔴 ApiClient: Response data: ${e.response?.data}');

      return ApiResponse<T>(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['message'] ?? e.message,
      );
    } catch (e, stackTrace) {
      log('🔴 ApiClient: POST $path - Unexpected error - $e');
      log('🔴 Stack trace: $stackTrace');
      return ApiResponse<T>(statusCode: 500, message: 'Network error occurred');
    }
  }
}
