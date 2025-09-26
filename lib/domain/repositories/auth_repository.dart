import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String username, String password);
  Future<User> register(String username, String email, String password, String firstName, String lastName);
  Future<User> getCurrentUser(String token);
  Future<User> refreshToken(String refreshToken);
  Future<void> logout();
  Future<User?> getCachedUser();
  Future<bool> isLoggedIn();
}
