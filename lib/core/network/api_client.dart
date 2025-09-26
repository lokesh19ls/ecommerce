import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/api_constants.dart';
import '../errors/failures.dart';

class ApiClient {
  late final Dio _dio;
  final Connectivity _connectivity = Connectivity();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
      headers: ApiConstants.defaultHeaders,
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      if (!await _hasInternetConnection()) {
        throw const NetworkFailure(message: 'No internet connection');
      }

      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      if (!await _hasInternetConnection()) {
        throw const NetworkFailure(message: 'No internet connection');
      }

      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      if (!await _hasInternetConnection()) {
        throw const NetworkFailure(message: 'No internet connection');
      }

      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      if (!await _hasInternetConnection()) {
        throw const NetworkFailure(message: 'No internet connection');
      }

      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(message: 'Connection timeout');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Server error';
        if (statusCode == 401) {
          return const AuthFailure(message: 'Unauthorized');
        } else if (statusCode == 403) {
          return const AuthFailure(message: 'Forbidden');
        } else if (statusCode == 404) {
          return const ServerFailure(message: 'Not found');
        } else if (statusCode! >= 500) {
          return const ServerFailure(message: 'Internal server error');
        } else {
          return ServerFailure(message: message);
        }
      case DioExceptionType.cancel:
        return const NetworkFailure(message: 'Request cancelled');
      case DioExceptionType.connectionError:
        return const NetworkFailure(message: 'Connection error');
      case DioExceptionType.badCertificate:
        return const NetworkFailure(message: 'Bad certificate');
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return const NetworkFailure(message: 'No internet connection');
        }
        return ServerFailure(message: error.message ?? 'Unknown error');
    }
  }
}
