import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearUserCache();
  Future<String?> getCachedToken();
  Future<void> cacheToken(String token);
  Future<void> clearToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _sharedPreferences;

  AuthLocalDataSourceImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = _sharedPreferences.getString(AppConstants.userDataKey);
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      throw const CacheFailure(message: 'Failed to get cached user');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await _sharedPreferences.setString(AppConstants.userDataKey, userJson);
    } catch (e) {
      throw const CacheFailure(message: 'Failed to cache user');
    }
  }

  @override
  Future<void> clearUserCache() async {
    try {
      await _sharedPreferences.remove(AppConstants.userDataKey);
    } catch (e) {
      throw const CacheFailure(message: 'Failed to clear user cache');
    }
  }

  @override
  Future<String?> getCachedToken() async {
    try {
      return _sharedPreferences.getString(AppConstants.userTokenKey);
    } catch (e) {
      throw const CacheFailure(message: 'Failed to get cached token');
    }
  }

  @override
  Future<void> cacheToken(String token) async {
    try {
      await _sharedPreferences.setString(AppConstants.userTokenKey, token);
    } catch (e) {
      throw const CacheFailure(message: 'Failed to cache token');
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await _sharedPreferences.remove(AppConstants.userTokenKey);
    } catch (e) {
      throw const CacheFailure(message: 'Failed to clear token');
    }
  }
}
