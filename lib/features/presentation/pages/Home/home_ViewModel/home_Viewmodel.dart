// filepath: lib/features/presentation/pages/Wallet/Wallet_ViewModel/wallet_view_model.dart


import 'package:cryphoria_mobile/features/domain/entities/wallet.dart';
import 'package:cryphoria_mobile/features/domain/usecases/wallet/wallet_usecase.dart';
import 'package:flutter/material.dart';

class WalletViewModel extends ChangeNotifier {
  final GetWalletsUseCase getWalletsUseCase;

  WalletViewModel({required this.getWalletsUseCase});

  List<Wallet> _wallets = [];
  List<Wallet> get wallets => _wallets;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchWallets() async {
    _isLoading = true;
    notifyListeners();
    try {
      _wallets = await getWalletsUseCase.call();
    } catch (e) {
      // Handle any errors accordingly
    }
    _isLoading = false;
    notifyListeners();
  }
}