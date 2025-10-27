// core/network/api_client.dart
import 'dart:io';
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
            final token = await _secureStorage.read(key: 'auth_token');
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
            await _secureStorage.delete(key: 'auth_token');
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
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );

      return ApiResponse<T>(
        data: response.data,
        statusCode: response.statusCode!,
      );
    } on DioException catch (e) {
      return ApiResponse<T>(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['message'] ?? e.message,
      );
    } catch (e) {
      return ApiResponse<T>(statusCode: 500, message: 'Network error occurred');
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    bool requiresAuth = false,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );

      return ApiResponse<T>(
        data: response.data,
        statusCode: response.statusCode!,
      );
    } on DioException catch (e) {
      return ApiResponse<T>(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['message'] ?? e.message,
      );
    } catch (e) {
      return ApiResponse<T>(statusCode: 500, message: 'Network error occurred');
    }
  }
}
