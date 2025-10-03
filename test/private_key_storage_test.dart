// import 'package:flutter_test/flutter_test.dart';
// import 'package:cryphoria_mobile/features/data/services/private_key_storage.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class _FakeSecureStorage extends FlutterSecureStorage {}

// class MemoryStorage extends PrivateKeyStorage {
//   final Map<String, String> _data = {};
//   MemoryStorage() : super(storage: _FakeSecureStorage());

//   @override
//   Future<void> saveKey(String key) async {
//     _data['wallet_private_key'] = key;
//   }

//   @override
//   Future<String?> readKey() async => _data['wallet_private_key'];

//   @override
//   Future<void> clearKey() async {
//     _data.remove('wallet_private_key');
//   }
// }

// void main() {
//   test('stores and retrieves private key', () async {
//     final storage = MemoryStorage();
//     await storage.saveKey('secret');
//     expect(await storage.readKey(), 'secret');
//     await storage.clearKey();
//     expect(await storage.readKey(), isNull);
//   });
// }
