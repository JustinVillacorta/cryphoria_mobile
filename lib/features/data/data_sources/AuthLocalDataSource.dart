import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const _tokenKey = 'auth_token';

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheToken(String token) async {
    await secureStorage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return secureStorage.read(key: _tokenKey);
  }
}
