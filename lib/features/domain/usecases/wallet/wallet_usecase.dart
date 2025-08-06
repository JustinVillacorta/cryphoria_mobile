
import 'package:cryphoria_mobile/features/domain/entities/wallet.dart';
import 'package:cryphoria_mobile/features/domain/repositories/wallet_repository.dart';

class GetWalletsUseCase {
  final WalletRepository repository;
  GetWalletsUseCase(this.repository);

  Future<List<Wallet>> call() async {
    return repository.getWallets();
  }
}

class ConnectWalletUseCase {
  final WalletRepository repository;
  ConnectWalletUseCase(this.repository);

  Future<Wallet> execute({
    required String walletType,
    required String address,
    required String signature,
  }) {
    return repository.connectWallet(
      walletType: walletType,
      address: address,
      signature: signature,
    );
  }
}