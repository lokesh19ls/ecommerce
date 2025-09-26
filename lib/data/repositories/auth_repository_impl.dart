import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<User> login(String username, String password) async {
    try {
      final userModel = await _remoteDataSource.login(username, password);
      
      // Cache user data and token
      await _localDataSource.cacheUser(userModel);
      if (userModel.token != null) {
        await _localDataSource.cacheToken(userModel.token!);
      }
      
      return userModel;
    } on Failure {
      rethrow;
    } catch (e) {
      throw const AuthFailure(message: 'Login failed');
    }
  }

  @override
  Future<User> register(String username, String email, String password, String firstName, String lastName) async {
    try {
      final userModel = await _remoteDataSource.register(username, email, password, firstName, lastName);
      
      // Cache user data and token
      await _localDataSource.cacheUser(userModel);
      if (userModel.token != null) {
        await _localDataSource.cacheToken(userModel.token!);
      }
      
      return userModel;
    } on Failure {
      rethrow;
    } catch (e) {
      throw const AuthFailure(message: 'Registration failed');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
      await _localDataSource.clearUserCache();
      await _localDataSource.clearToken();
    } on Failure {
      rethrow;
    } catch (e) {
      throw const AuthFailure(message: 'Logout failed');
    }
  }

  @override
  Future<User> getCurrentUser(String token) async {
    try {
      final userModel = await _remoteDataSource.getCurrentUser(token);
      
      // Update cached user data
      await _localDataSource.cacheUser(userModel);
      if (userModel.token != null) {
        await _localDataSource.cacheToken(userModel.token!);
      }
      
      return userModel;
    } on Failure {
      rethrow;
    } catch (e) {
      throw const AuthFailure(message: 'Failed to get current user');
    }
  }

  @override
  Future<User> refreshToken(String refreshToken) async {
    try {
      final userModel = await _remoteDataSource.refreshToken(refreshToken);
      
      // Update cached user data and token
      await _localDataSource.cacheUser(userModel);
      if (userModel.token != null) {
        await _localDataSource.cacheToken(userModel.token!);
      }
      
      return userModel;
    } on Failure {
      rethrow;
    } catch (e) {
      throw const AuthFailure(message: 'Token refresh failed');
    }
  }

  @override
  Future<User?> getCachedUser() async {
    try {
      return await _localDataSource.getCachedUser();
    } on Failure {
      rethrow;
    } catch (e) {
      throw const CacheFailure(message: 'Failed to get cached user');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await _localDataSource.getCachedToken();
      return token != null && token.isNotEmpty;
    } on Failure {
      rethrow;
    } catch (e) {
      return false;
    }
  }
}
