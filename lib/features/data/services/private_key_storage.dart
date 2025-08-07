import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class PrivateKeyStorage {
  static const _key = 'wallet_private_key';
  final FlutterSecureStorage _storage;
  final Dio _dio;
  final String apiUrl;

  PrivateKeyStorage({
    FlutterSecureStorage? storage,
    Dio? dio,
    String? apiUrl,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _dio = dio ?? Dio(),
        apiUrl = apiUrl ?? 'http://localhost:8000/api/private_keys/';

  Future<void> saveKey(String key, {required String walletName}) async {
    await _storage.write(key: _key, value: key);
    await _dio.post(
      apiUrl,
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: {'private_key': key, 'wallet_name': walletName},
    );
  }

  Future<String?> readKey() => _storage.read(key: _key);

  Future<void> clearKey() => _storage.delete(key: _key);
}
