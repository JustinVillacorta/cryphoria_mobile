// filepath: lib/features/presentation/pages/Wallet/Wallet_ViewModel/wallet_view_model.dart


import 'package:cryphoria_mobile/features/domain/entities/wallet.dart';
import 'package:cryphoria_mobile/features/domain/usecases/wallet/wallet_usecase.dart';
import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/data/services/wallet_connector_service.dart';

class WalletViewModel extends ChangeNotifier {
  final GetWalletsUseCase getWalletsUseCase;
  final ConnectWalletUseCase connectWalletUseCase;
  final WalletConnectorService walletConnectorService;

  WalletViewModel({
    required this.getWalletsUseCase,
    required this.connectWalletUseCase,
    required this.walletConnectorService,
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
  /// Initiates a WalletConnect flow via [WalletConnectorService] and returns
  /// the resulting wallet address and signature.
  Future<Map<String, String>> initiateWalletConnect(String walletType) async {
    final (address, signature) = await walletConnectorService.connectAndSign(
      wallet: walletType,
      message: 'Connect to Cryphoria',
    );
    return {'address': address, 'signature': signature};
  }

  Future<void> connectWallet({
    required String walletType,
    required String address,
    required String signature,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newWallet = await connectWalletUseCase.execute(
        walletType: walletType,
        address: address,
        signature: signature,
      );
      _wallets.insert(0, newWallet);
    } catch (e) {
      // handle error
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }




}