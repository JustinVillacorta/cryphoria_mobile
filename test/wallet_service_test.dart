import 'package:flutter_test/flutter_test.dart';
import 'package:cryphoria_mobile/features/data/services/wallet_service.dart';
import 'package:cryphoria_mobile/features/data/data_sources/walletRemoteDataSource.dart';
import 'package:web3dart/credentials.dart';
import 'private_key_storage_test.dart';

class FakeRemote extends WalletRemoteDataSource {
  FakeRemote() : super();

  @override
  Future<void> registerWallet({
    required String endpoint,
    required String walletAddress,
    required String walletName,
    required String walletType,
  }) async {}

  @override
  Future<double> getBalance(String walletAddress) async {
    return 5.0;
  }
}

class NotFoundRemote extends WalletRemoteDataSource {
  NotFoundRemote() : super();

  @override
  Future<double> getBalance(String walletAddress) async {
    throw WalletNotFoundException();
  }
}

void main() {
  test('connect stores key and returns wallet', () async {
    const key =
        '0x8f2a559490cc2a7ab61c32ed3d8060216ee02e4960a83f97bde6ceb39d4b4d5e';
    final service = WalletService(
      remoteDataSource: FakeRemote(),
      storage: MemoryStorage(),
    );
    final wallet = await service.connectWallet(
      key,
      endpoint: 'connect_trust_wallet/',
      walletName: 'Mobile Wallet',
      walletType: 'Trust Wallet',
    );
    final expected = EthPrivateKey.fromHex(key).address.hexEip55;
    expect(wallet.address, expected);
    expect(wallet.balance, 5.0);
  });

  test('reconnect uses stored key', () async {
    const key =
        '0x8f2a559490cc2a7ab61c32ed3d8060216ee02e4960a83f97bde6ceb39d4b4d5e';
    final storage = MemoryStorage();
    await storage.saveKey(key);
    final service = WalletService(
      remoteDataSource: FakeRemote(),
      storage: storage,
    );
    final wallet = await service.reconnect();
    expect(wallet?.balance, 5.0);
  });

  test('reconnect returns null when wallet missing', () async {
    const key =
        '0x8f2a559490cc2a7ab61c32ed3d8060216ee02e4960a83f97bde6ceb39d4b4d5e';
    final storage = MemoryStorage();
    await storage.saveKey(key);
    final service = WalletService(
      remoteDataSource: NotFoundRemote(),
      storage: storage,
    );
    final wallet = await service.reconnect();
    expect(wallet, isNull);
  });
}

