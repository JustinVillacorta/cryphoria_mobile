import '../entities/auth_user.dart';
import '../entities/login_response.dart';
import '../entities/user_session.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(String username, String password, {String? deviceName, String? deviceId});
  Future<LoginResponse> register(String username, String password, String email, {String? role, String? deviceName, String? deviceId});
  
  // Session management - aligned with backend API
  Future<Map<String, dynamic>> logoutCheck(); // Check if safe logout is possible
  Future<bool> logoutForce(); // Force logout without transfer check
  Future<List<UserSession>> getTransferableSessions(); // List transferable sessions
  Future<bool> transferMainDevice(String sessionId); // Transfer main device privileges
  Future<bool> confirmPassword(String password);
  Future<bool> validateSession();
  
  // Local token management
  Future<void> cacheAuthUser(AuthUser user);
  Future<AuthUser?> getCachedAuthUser();
  Future<void> clearCache();
}