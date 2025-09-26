import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
  Future<UserModel> register(String username, String email, String password, String firstName, String lastName);
  Future<UserModel> getCurrentUser(String token);
  Future<UserModel> refreshToken(String refreshToken);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  final Dio _authDio;

  AuthRemoteDataSourceImpl({
    required ApiClient apiClient,
  })  : _apiClient = apiClient,
        _authDio = Dio(BaseOptions(
          baseUrl: ApiConstants.authBaseUrl,
          connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
          receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
          sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
          headers: ApiConstants.defaultHeaders,
        ));

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _authDio.post(
        ApiConstants.loginEndpoint,
        data: {
          'username': username,
          'password': password,
          'expiresInMins': 60, // Token expires in 60 minutes
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }

      throw const AuthFailure(message: 'Login failed');
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw const AuthFailure(message: 'Invalid username or password');
      }
      throw const AuthFailure(message: 'Login failed');
    } catch (e) {
      throw const AuthFailure(message: 'Login failed');
    }
  }

  @override
  Future<UserModel> register(String username, String email, String password, String firstName, String lastName) async {
    try {
      final response = await _authDio.post(
        ApiConstants.registerEndpoint,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data);
      }

      throw const AuthFailure(message: 'Registration failed');
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final error = e.response?.data;
        if (error != null && error['message'] != null) {
          throw AuthFailure(message: error['message']);
        }
        throw const AuthFailure(message: 'Username or email already exists');
      }
      throw const AuthFailure(message: 'Registration failed');
    } catch (e) {
      throw const AuthFailure(message: 'Registration failed');
    }
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    try {
      final response = await _authDio.get(
        ApiConstants.meEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }

      throw const AuthFailure(message: 'Failed to get current user');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthFailure(message: 'Unauthorized - invalid token');
      }
      throw const AuthFailure(message: 'Failed to get current user');
    } catch (e) {
      throw const AuthFailure(message: 'Failed to get current user');
    }
  }

  @override
  Future<UserModel> refreshToken(String refreshToken) async {
    try {
      final response = await _authDio.post(
        ApiConstants.refreshEndpoint,
        data: {
          'refreshToken': refreshToken,
          'expiresInMins': 60,
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }

      throw const AuthFailure(message: 'Token refresh failed');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthFailure(message: 'Invalid refresh token');
      }
      throw const AuthFailure(message: 'Token refresh failed');
    } catch (e) {
      throw const AuthFailure(message: 'Token refresh failed');
    }
  }

  @override
  Future<void> logout() async {
    // For demo purposes, we'll just return success
    // In a real app, you might want to call a logout endpoint
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
