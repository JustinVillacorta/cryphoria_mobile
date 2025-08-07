import '../data_sources/walletRemoteDataSource.dart';
import '../../domain/entities/wallet.dart';
import 'private_key_storage.dart';
import 'package:web3dart/credentials.dart';

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
      walletAddress: address,
      walletName: walletName,
      walletType: walletType,
    );
    final balance = await remoteDataSource.getBalance(address);
    return Wallet(id: '', name: walletName, address: address, balance: balance);
  }

  Future<Wallet?> reconnect() async {
    final key = await storage.readKey();
    if (key == null) return null;
    final address = EthPrivateKey.fromHex(key).address.hexEip55;
    final balance = await remoteDataSource.getBalance(address);
    return Wallet(id: '', name: 'Stored Wallet', address: address, balance: balance);
  }
}
