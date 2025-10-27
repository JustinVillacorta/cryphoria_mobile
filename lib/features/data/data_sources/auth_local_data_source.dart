import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/auth_user.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAuthUser(AuthUser user);
  Future<AuthUser?> getAuthUser();
  Future<void> clearAuthData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const _authUserKey = 'auth_user';

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
        await clearAuthData();
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearAuthData() async {
    await secureStorage.delete(key: _authUserKey);
  }
}

