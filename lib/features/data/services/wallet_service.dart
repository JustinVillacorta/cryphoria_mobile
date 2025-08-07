import '../data_sources/walletRemoteDataSource.dart';
import '../../domain/entities/wallet.dart';
import 'private_key_storage.dart';

class WalletService {
  final WalletRemoteDataSource remoteDataSource;
  final PrivateKeyStorage storage;

  WalletService({required this.remoteDataSource, required this.storage});

  Future<Wallet> connectWithPrivateKey(
    String privateKey, {
    required String endpoint,
    required String walletName,
  }) async {
    final address = await remoteDataSource.connectWithPrivateKey(
      endpoint: endpoint,
      privateKey: privateKey,
      walletName: walletName,
    );
    await storage.saveKey(privateKey);
    final balance = await remoteDataSource.getBalance(address);
    return Wallet(id: '', name: walletName, address: address, balance: balance);
  }

  Future<Wallet?> reconnect() async {
    final key = await storage.readKey();
    if (key == null) return null;
    final address = await remoteDataSource.reconnectWithPrivateKey(key);
    final balance = await remoteDataSource.getBalance(address);
    return Wallet(id: '', name: 'Stored Wallet', address: address, balance: balance);
  }
}
