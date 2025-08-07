import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PrivateKeyStorage {
  static const _key = 'wallet_private_key';
  final FlutterSecureStorage _storage;

  PrivateKeyStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveKey(String key) => _storage.write(key: _key, value: key);

  Future<String?> readKey() => _storage.read(key: _key);

  Future<void> clearKey() => _storage.delete(key: _key);
}
