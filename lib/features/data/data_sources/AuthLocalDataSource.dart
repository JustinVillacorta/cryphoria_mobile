import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/auth_user.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAuthUser(AuthUser user);
  Future<AuthUser?> getAuthUser();
  Future<void> clearAuthData();
  
  // Legacy support
  @deprecated
  Future<void> cacheToken(String token);
  @deprecated
  Future<String?> getToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const _authUserKey = 'auth_user';
  static const _tokenKey = 'auth_token'; // Legacy support

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheAuthUser(AuthUser user) async {
    final userJson = jsonEncode(user.toJson());
    await secureStorage.write(key: _authUserKey, value: userJson);
  }

  @override
  Future<AuthUser?> getAuthUser() async {
    final userJson = await secureStorage.read(key: _authUserKey);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return AuthUser.fromJson(userMap);
      } catch (e) {
        // If parsing fails, clear corrupted data
        await clearAuthData();
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearAuthData() async {
    await secureStorage.delete(key: _authUserKey);
    await secureStorage.delete(key: _tokenKey); // Also clear legacy token
  }

  // Legacy support methods
  @override
  @deprecated
  Future<void> cacheToken(String token) async {
    await secureStorage.write(key: _tokenKey, value: token);
  }

  @override
  @deprecated
  Future<String?> getToken() async {
    // First try to get token from new AuthUser structure
    final authUser = await getAuthUser();
    if (authUser != null) {
      return authUser.token;
    }
    
    // Fallback to legacy token storage
    return secureStorage.read(key: _tokenKey);
  }
}
