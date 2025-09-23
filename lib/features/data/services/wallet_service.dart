import 'package:flutter/cupertino.dart';

import '../data_sources/walletRemoteDataSource.dart';
import '../../domain/entities/wallet.dart';
import 'private_key_storage.dart';
import 'currency_conversion_service.dart';
import 'package:web3dart/credentials.dart' hide Wallet;

class WalletService {
  final WalletRemoteDataSource remoteDataSource;
  final PrivateKeyStorage storage;
  final CurrencyConversionService currencyService;

  WalletService({
    required this.remoteDataSource, 
    required this.storage,
    required this.currencyService,
  });

  Future<Wallet> connectWallet(
    String privateKey, {
    required String endpoint,
    required String walletName,
    required String walletType,
  }) async {
    await storage.saveKey(privateKey);
    final creds = EthPrivateKey.fromHex(privateKey);
    final address = creds.address.hexEip55;

    // Connect wallet and get wallet data from backend
    final walletData = await remoteDataSource.registerWallet(
      endpoint: endpoint,
      privateKey: privateKey,
      walletName: walletName,
      walletType: walletType,
    );

    // Extract balance from backend response or use blockchain endpoint as fallback
    double balance = 0.0;
    try {
      balance = double.tryParse(walletData['balances']?['ETH']?['balance']?.toString() ?? '') ?? 0.0;
    } catch (e) {
      balance = 0.0;
    }

// ✅ Always fetch from blockchain if balance is still 0
    if (balance <= 0.0) {
      balance = await remoteDataSource.getBalance(address);
    }


    // Convert ETH balance to both PHP and USD
    final rates = await currencyService.getETHRates();
    final balanceInPHP = balance * (rates['php'] ?? 0.0);
    final balanceInUSD = balance * (rates['usd'] ?? 0.0);
    return Wallet(
      id: walletData['wallet_id']?.toString() ?? '',
      name: walletName,
      private_key: privateKey,
      balance: balance,
      balanceInPHP: balanceInPHP,
      balanceInUSD: balanceInUSD,
      address: address,
      walletType: walletType,
    );
  }

  Future<bool> hasStoredWallet() async {
    final key = await storage.readKey();
    return key != null && key.isNotEmpty;
  }

  Future<void> disconnect() async {
    await storage.clearKey();
  }

  Future<Wallet?> reconnect() async {
    final key = await storage.readKey();
    if (key == null || key.isEmpty) return null;

    final address = EthPrivateKey.fromHex(key).address.hexEip55;
    try {
      final walletData = await remoteDataSource.reconnectWallet(
        privateKey: key,
      );

      double balance = 0.0;
      try {
        balance = double.tryParse(walletData['balances']?['ETH']?['balance']?.toString() ?? '0') ?? 0.0;
        if (balance == 0.0) {
          balance = await remoteDataSource.getBalance(address);
        }
      } catch (e) {
        balance = await remoteDataSource.getBalance(address);
      }

      final rates = await currencyService.getETHRates();
      final balanceInPHP = balance * (rates['php'] ?? 0.0);
      final balanceInUSD = balance * (rates['usd'] ?? 0.0);

      return Wallet(
        id: walletData['wallet_id']?.toString() ?? '',
        name: walletData['name']?.toString() ?? 'MetaMask',
        private_key: key,
        balance: balance,
        balanceInPHP: balanceInPHP,
        balanceInUSD: balanceInUSD,
        address: address,
        walletType: walletData['wallet_type']?.toString() ?? 'MetaMask',
      );
    } on WalletNotFoundException {
      return null;
    }
  }

  /// ✅ ADD THIS NEW METHOD HERE
  Future<Wallet> refreshBalance(Wallet wallet) async {
    final address = (wallet.address.isNotEmpty)
        ? wallet.address
        : EthPrivateKey.fromHex(wallet.private_key).address.hexEip55;

    double balance = 0.0;
    try {
      balance = await remoteDataSource.getBalance(address);
    } catch (e) {
      debugPrint('WalletService.refreshBalance: getBalance failed: $e');
      balance = 0.0;
    }

    final rates = await currencyService.getETHRates();
    final balanceInPHP = balance * (rates['php'] ?? 0.0);
    final balanceInUSD = balance * (rates['usd'] ?? 0.0);

    return wallet.copyWith(
      balance: balance,
      balanceInPHP: balanceInPHP,
      balanceInUSD: balanceInUSD,
      address: address,
    );
  }

}
