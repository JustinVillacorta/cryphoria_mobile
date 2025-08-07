import 'package:cryphoria_mobile/features/data/services/private_key_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

class FakeSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({required String key, String? value, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WindowsOptions? wOptions, WebOptions? webOptions, MacOsOptions? mOptions}) async {
    _data[key] = value ?? '';
  }

  @override
  Future<String?> read({required String key, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WindowsOptions? wOptions, WebOptions? webOptions, MacOsOptions? mOptions}) async {
    return _data[key];
  }

  @override
  Future<void> delete({required String key, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WindowsOptions? wOptions, WebOptions? webOptions, MacOsOptions? mOptions}) async {
    _data.remove(key);
  }
}

class FakeDio extends Dio {
  Map<String, dynamic>? lastData;

  @override
  Future<Response<T>> post<T>(String path,{data, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) async {
    lastData = data as Map<String, dynamic>?;
    return Response<T>(data: {} as T, statusCode: 200, requestOptions: RequestOptions(path: path));
  }
}

class MemoryStorage extends PrivateKeyStorage {
  final Map<String, String> _data = {};
  MemoryStorage()
      : super(storage: FakeSecureStorage(), dio: FakeDio());

  @override
  Future<void> saveKey(String key, {required String walletName}) async {
    _data['wallet_private_key'] = key;
  }

  @override
  Future<String?> readKey() async => _data['wallet_private_key'];

  @override
  Future<void> clearKey() async {
    _data.remove('wallet_private_key');
  }
}

void main() {
  test('stores, posts, and retrieves private key', () async {
    final fakeStorage = FakeSecureStorage();
    final fakeDio = FakeDio();
    final storage = PrivateKeyStorage(storage: fakeStorage, dio: fakeDio, apiUrl: 'http://example.com');
    await storage.saveKey('secret', walletName: 'MyWallet');
    expect(await storage.readKey(), 'secret');
    expect(fakeDio.lastData, {
      'private_key': 'secret',
      'wallet_name': 'MyWallet',
    });
    await storage.clearKey();
    expect(await storage.readKey(), isNull);
  });
}
