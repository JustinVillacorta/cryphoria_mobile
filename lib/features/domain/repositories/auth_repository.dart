import '../entities/auth_user.dart';
import '../entities/login_response.dart';
import '../entities/user_session.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(String username, String password, {String? deviceName, String? deviceId});
  Future<LoginResponse> register(String username, String password, String email, {String? deviceName, String? deviceId});
  
  // Session management
  Future<List<UserSession>> getSessions();
  Future<bool> approveSession(String sessionId);
  Future<bool> revokeSession(String sessionId);
  Future<bool> revokeOtherSessions();
  Future<bool> logout();
  Future<bool> confirmPassword(String password);
  
  // Local token management
  Future<void> cacheAuthUser(AuthUser user);
  Future<AuthUser?> getCachedAuthUser();
  Future<void> clearCache();
}