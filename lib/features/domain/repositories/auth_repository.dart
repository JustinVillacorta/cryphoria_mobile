import '../entities/auth_user.dart';
import '../entities/login_response.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(String email, String password);
  Future<LoginResponse> register(String username, String password, String passwordConfirm, String email, String firstName, String lastName, String securityAnswer, {String? role});
  
  // Basic authentication
  Future<bool> logout();
  Future<bool> validateSession();
  
  // Local token management
  Future<void> cacheAuthUser(AuthUser user);
  Future<AuthUser?> getCachedAuthUser();
  Future<void> clearCache();
}