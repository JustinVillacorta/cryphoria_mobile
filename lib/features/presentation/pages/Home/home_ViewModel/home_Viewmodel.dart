import 'package:cryphoria_mobile/features/data/services/wallet_service.dart';
import 'package:cryphoria_mobile/features/domain/entities/wallet.dart';
import 'package:flutter/material.dart';


class WalletViewModel extends ChangeNotifier {
  final WalletService walletService;

  WalletViewModel({required this.walletService});

  Wallet? _wallet;
  bool _isLoading = false;

  Wallet? get wallet => _wallet;
  bool get isLoading => _isLoading;

  Future<void> connect(
    String privateKey, {
    required String endpoint,
    required String walletName,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _wallet = await walletService.connectWallet(
        privateKey,
        endpoint: endpoint,
        walletName: walletName,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reconnect() async {
    _isLoading = true;
    notifyListeners();
    try {
      _wallet = await walletService.reconnect();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
