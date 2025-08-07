import 'package:flutter_test/flutter_test.dart';
import 'package:cryphoria_mobile/features/data/services/wallet_service.dart';
import 'package:cryphoria_mobile/features/data/data_sources/walletRemoteDataSource.dart';
import 'private_key_storage_test.dart';

class FakeRemote extends WalletRemoteDataSource {
  FakeRemote() : super(token: '');
  @override
  Future<String> connectWithPrivateKey({required String endpoint, required String privateKey, required String walletName}) async {
    return 'addr';
  }

  @override
  Future<String> reconnectWithPrivateKey(String privateKey) async {
    return 'addr';
  }

  @override
  Future<double> getBalance(String walletAddress) async {
    return 5.0;
  }
}

void main() {
  test('connect stores key and returns wallet', () async {
    final service = WalletService(
      remoteDataSource: FakeRemote(),
      storage: MemoryStorage(),
    );
    final wallet = await service.connectWithPrivateKey('k');
    expect(wallet.address, 'addr');
    expect(wallet.balance, 5.0);
  });

  test('reconnect uses stored key', () async {
    final storage = MemoryStorage();
    await storage.saveKey('k');
    final service = WalletService(
      remoteDataSource: FakeRemote(),
      storage: storage,
    );
    final wallet = await service.reconnect();
    expect(wallet?.balance, 5.0);
  });
}
