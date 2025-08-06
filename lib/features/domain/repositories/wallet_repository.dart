// filepath: lib/features/domain/repositories/wallet_repository.dart
import '../entities/wallet.dart';

abstract class WalletRepository {
  Future<List<Wallet>> getWallets();
  Future<Wallet> addWallet(Wallet wallet);
  Future<Wallet> connectWallet({
    required String walletType,
    required String privateKey,
    String walletName = '',
  });
}