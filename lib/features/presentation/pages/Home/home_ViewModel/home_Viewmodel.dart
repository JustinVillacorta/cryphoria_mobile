// filepath: lib/features/presentation/pages/Wallet/Wallet_ViewModel/wallet_view_model.dart


import 'package:cryphoria_mobile/features/domain/entities/wallet.dart';
import 'package:cryphoria_mobile/features/domain/usecases/wallet/wallet_usecase.dart';
import 'package:flutter/material.dart';

class WalletViewModel extends ChangeNotifier {
  final GetWalletsUseCase getWalletsUseCase;
  final ConnectWalletUseCase connectWalletUseCase;

  WalletViewModel({
    required this.getWalletsUseCase,
    required this.connectWalletUseCase,
  });

 List<Wallet> _wallets = [];
  bool _isLoading = false;
  List<Wallet> get wallets => _wallets;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  Future<void> fetchWallets() async {
    isLoading = true;
    try {
      _wallets = await getWalletsUseCase.call();
    } catch (e) {
      // Handle any errors accordingly
    }
    _isLoading = false;
    notifyListeners();
  }
  Future<void> connectWallet({
    required String walletType,
    required String address,
    required String signature,
    String walletName = '',
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newWallet = await connectWalletUseCase.execute(
        walletType: walletType,
        address: address,
        signature: signature,
        walletName: walletName,
      );
      _wallets.insert(0, newWallet);
    } catch (e) {
      // handle error
    }
    _isLoading = false;
    notifyListeners();
  }




}