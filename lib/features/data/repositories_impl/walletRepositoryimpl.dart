import 'package:cryphoria_mobile/features/data/data_sources/walletRemoteDataSource.dart';
import 'package:cryphoria_mobile/features/domain/entities/wallet.dart';
import 'package:cryphoria_mobile/features/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Wallet>> getWallets() async {
    return await remoteDataSource.fetchWallets();
  }

  @override
  Future<Wallet> addWallet(Wallet wallet) async {
    return await remoteDataSource.createWallet(wallet);
  }

 @override
  Future<Wallet> connectWallet({
    required String walletType,
    required String address,
    required String signature,
  }) {
    return remoteDataSource.connectWallet(
      walletType: walletType,
      address: address,
      signature: signature,
    );
  }







}
