
import 'package:cryphoria_mobile/features/domain/entities/wallet.dart';
import 'package:cryphoria_mobile/features/domain/repositories/wallet_repository.dart';

class GetWalletsUseCase {
  final WalletRepository repository;
  GetWalletsUseCase(this.repository);

  Future<List<Wallet>> call() async {
    return repository.getWallets();
  }
}