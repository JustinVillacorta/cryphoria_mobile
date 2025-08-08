import '../data_sources/walletRemoteDataSource.dart';
import '../../domain/entities/wallet.dart';
import 'private_key_storage.dart';
import 'package:web3dart/credentials.dart' hide Wallet;

class WalletService {
  final WalletRemoteDataSource remoteDataSource;
  final PrivateKeyStorage storage;

  WalletService({required this.remoteDataSource, required this.storage});

  Future<Wallet> connectWallet(
    String privateKey, {
    required String endpoint,
    required String walletName,
    required String walletType,
  }) async {
    await storage.saveKey(privateKey);
    final creds = EthPrivateKey.fromHex(privateKey);
    final address = creds.address.hexEip55;

    await remoteDataSource.registerWallet(
      endpoint: endpoint,
      privateKey: privateKey, // send private_key to server
      walletName: walletName,
      walletType: walletType,
    );

    // Use address for balance lookup
    final balance = await remoteDataSource.getBalance(address);
    return Wallet(id: '', name: walletName, private_key: privateKey, balance: balance);
  }

  Future<bool> hasStoredWallet() async {
    final key = await storage.readKey();
    return key != null && key.isNotEmpty;
  }

  Future<Wallet?> reconnect() async {
    final key = await storage.readKey();
    if (key == null || key.isEmpty) return null;

    final address = EthPrivateKey.fromHex(key).address.hexEip55;
    try {
      final balance = await remoteDataSource.getBalance(address);
      return Wallet(id: '', name: 'Stored Wallet', private_key: key, balance: balance);
    } on WalletNotFoundException {
      return null;
    }
  }
}
