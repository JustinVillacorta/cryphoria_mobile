import 'package:flutter/material.dart';
import '../../../domain/entities/wallet.dart';
import '../../../data/services/wallet_service.dart';

class WalletViewModel extends ChangeNotifier {
  final WalletService walletService;

  WalletViewModel({required this.walletService});

  Wallet? _wallet;
  bool _isLoading = false;

  Wallet? get wallet => _wallet;
  bool get isLoading => _isLoading;

  Future<void> connect(String privateKey) async {
    _isLoading = true;
    notifyListeners();
    try {
      _wallet = await walletService.connectWithPrivateKey(privateKey);
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
