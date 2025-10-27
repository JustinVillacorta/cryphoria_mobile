import 'package:flutter/cupertino.dart';

import '../data_sources/wallet_remote_data_source.dart';
import '../../domain/entities/wallet.dart';
import 'currency_conversion_service.dart';
import 'package:web3dart/credentials.dart' hide Wallet;

class WalletService {
  final WalletRemoteDataSource remoteDataSource;
  final CurrencyConversionService currencyService;

  WalletService({
    required this.remoteDataSource, 
    required this.currencyService,
  });

  Future<Wallet> connectWallet(
    String privateKey, {
    required String walletName,
    required String walletType,
  }) async {
    final creds = EthPrivateKey.fromHex(privateKey);
    final address = creds.address.hexEip55;

    final walletData = await remoteDataSource.connectWallet(
      privateKey: privateKey,
      walletName: walletName,
      walletType: walletType,
    );

    double balance = 0.0;
    try {
      final walletData = await remoteDataSource.getWalletBalance();
      balance = (walletData['balance_eth'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      debugPrint('WalletService.connectWallet: getWalletBalance failed: $e');
      balance = 0.0;
    }

    double balanceInPHP = 0.0;
    double balanceInUSD = 0.0;

    try {
      final phpResult = await currencyService.convertCryptoToFiat(
        value: balance.toString(),
        from: 'ETH',
        to: 'PHP',
      );
      debugPrint('🔍 PHP conversion result: $phpResult');
      balanceInPHP = (phpResult['converted_amount'] as num?)?.toDouble() ?? 0.0;
      debugPrint('🔍 Parsed PHP balance: $balanceInPHP');

      final usdResult = await currencyService.convertCryptoToFiat(
        value: balance.toString(),
        from: 'ETH',
        to: 'USD',
      );
      debugPrint('🔍 USD conversion result: $usdResult');
      balanceInUSD = (usdResult['converted_amount'] as num?)?.toDouble() ?? 0.0;
      debugPrint('🔍 Parsed USD balance: $balanceInUSD');
    } catch (e) {
      debugPrint('WalletService.connectWallet: Conversion failed, using fallback rates: $e');
      final rates = await currencyService.getETHRates();
      balanceInPHP = balance * (rates['php'] ?? 0.0);
      balanceInUSD = balance * (rates['usd'] ?? 0.0);
    }

    return Wallet(
      id: walletData['wallet_address']?.toString() ?? address,
      name: walletData['wallet_name']?.toString() ?? walletName,
      balance: balance,
      balanceInPHP: balanceInPHP,
      balanceInUSD: balanceInUSD,
      address: walletData['wallet_address']?.toString() ?? address,
      walletType: walletData['wallet_type']?.toString() ?? walletType,
      isConnected: true,
    );
  }

  Future<bool> hasStoredWallet() async {
    try {
      final wallet = await getUserWallet();
      return wallet != null;
    } catch (e) {
      debugPrint('WalletService.hasStoredWallet: Failed to check stored wallet: $e');
      return false;
    }
  }

  Future<void> disconnect(Wallet wallet) async {
    try {
      await remoteDataSource.disconnectWallet(wallet.address);
    } catch (e) {
      debugPrint('WalletService.disconnect: Failed to disconnect wallet: $e');
    }
  }

  Future<Wallet?> getUserWallet() async {
    try {
      final walletData = await remoteDataSource.getWalletBalance();

      debugPrint('🔍 getUserWallet - Backend response: $walletData');

      if (walletData.isEmpty) {
        debugPrint('🔍 getUserWallet - Empty response, no wallet connected');
        return null;
      }

      final walletAddress = walletData['wallet_address']?.toString();
      final balanceEth = (walletData['balance_eth'] as num?)?.toDouble() ?? 0.0;

      debugPrint('🔍 getUserWallet - walletAddress: $walletAddress, balanceEth: $balanceEth');

      if (walletAddress == null || 
          walletAddress.isEmpty || 
          walletAddress == 'null' ||
          walletAddress == 'None' ||
          balanceEth == 0.0) {
        debugPrint('🔍 getUserWallet - No valid wallet data found, returning null');
        return null;
      }

      double balanceInPHP = 0.0;
      double balanceInUSD = 0.0;

      try {
        final phpResult = await currencyService.convertCryptoToFiat(
          value: balanceEth.toString(),
          from: 'ETH',
          to: 'PHP',
        );
        debugPrint('🔍 getUserWallet PHP conversion result: $phpResult');
        balanceInPHP = (phpResult['converted_amount'] as num?)?.toDouble() ?? 0.0;
        debugPrint('🔍 getUserWallet Parsed PHP balance: $balanceInPHP');

        final usdResult = await currencyService.convertCryptoToFiat(
          value: balanceEth.toString(),
          from: 'ETH',
          to: 'USD',
        );
        debugPrint('🔍 getUserWallet USD conversion result: $usdResult');
        balanceInUSD = (usdResult['converted_amount'] as num?)?.toDouble() ?? 0.0;
        debugPrint('🔍 getUserWallet Parsed USD balance: $balanceInUSD');
      } catch (e) {
        debugPrint('WalletService.getUserWallet: Conversion failed, using fallback rates: $e');
        final rates = await currencyService.getETHRates();
        balanceInPHP = balanceEth * (rates['php'] ?? 0.0);
        balanceInUSD = balanceEth * (rates['usd'] ?? 0.0);
      }

      final wallet = Wallet(
        id: walletAddress,
        name: 'Connected Wallet',
        balance: balanceEth,
        balanceInPHP: balanceInPHP,
        balanceInUSD: balanceInUSD,
        address: walletAddress,
        walletType: 'Private Key',
        isConnected: true,
      );

      debugPrint('🔍 getUserWallet - Returning wallet: ${wallet.toJson()}');
      return wallet;
    } catch (e) {
      debugPrint('WalletService.getUserWallet: Failed to get user wallet: $e');
      return null;
    }
  }

  Future<Wallet?> reconnect() async {
    return await getUserWallet();
  }

  Future<Wallet> refreshBalance(Wallet wallet) async {
    if (wallet.address.isEmpty) {
      throw Exception('Cannot refresh balance: wallet address is empty');
    }

    try {
      final walletData = await remoteDataSource.getWalletBalance();
      final balanceEth = (walletData['balance_eth'] as num?)?.toDouble() ?? 0.0;

      double balanceInPHP = 0.0;
      double balanceInUSD = 0.0;

      try {
        final phpResult = await currencyService.convertCryptoToFiat(
          value: balanceEth.toString(),
          from: 'ETH',
          to: 'PHP',
        );
        debugPrint('🔍 refreshBalance PHP conversion result: $phpResult');
        balanceInPHP = (phpResult['converted_amount'] as num?)?.toDouble() ?? 0.0;
        debugPrint('🔍 refreshBalance Parsed PHP balance: $balanceInPHP');

        final usdResult = await currencyService.convertCryptoToFiat(
          value: balanceEth.toString(),
          from: 'ETH',
          to: 'USD',
        );
        debugPrint('🔍 refreshBalance USD conversion result: $usdResult');
        balanceInUSD = (usdResult['converted_amount'] as num?)?.toDouble() ?? 0.0;
        debugPrint('🔍 refreshBalance Parsed USD balance: $balanceInUSD');
      } catch (e) {
        debugPrint('WalletService.refreshBalance: Conversion failed, using fallback rates: $e');
        final rates = await currencyService.getETHRates();
        balanceInPHP = balanceEth * (rates['php'] ?? 0.0);
        balanceInUSD = balanceEth * (rates['usd'] ?? 0.0);
      }

      return wallet.copyWith(
        balance: balanceEth,
        balanceInPHP: balanceInPHP,
        balanceInUSD: balanceInUSD,
      );
    } catch (e) {
      debugPrint('WalletService.refreshBalance: Failed to refresh balance: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendEth({
    required String toAddress,
    required double amount,
    String? gasPrice,
    String? gasLimit,
    String? company,
    String? category,
    String? description,
    bool? isInvesting,
    String? investorName,
  }) async {
      debugPrint('🌐 WalletService.sendEth called with:');
      debugPrint('📋 toAddress: $toAddress');
      debugPrint('📋 amount: $amount');
      debugPrint('📋 company: $company');
      debugPrint('📋 category: $category');
      debugPrint('📋 description: $description');
      debugPrint('📋 isInvesting: $isInvesting');
      debugPrint('📋 investorName: $investorName');
      debugPrint('📋 toAddress length: ${toAddress.length}');
      debugPrint('📋 toAddress starts with 0x: ${toAddress.startsWith('0x')}');

    return await remoteDataSource.sendEth(
      toAddress: toAddress,
      amount: amount,
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      company: company,
      category: category,
      description: description,
      isInvesting: isInvesting,
      investorName: investorName,
    );
  }

  Future<Map<String, dynamic>> convertCryptoToFiat({
    required String value,
    required String from,
    required String to,
  }) async {
    return await remoteDataSource.convertCryptoToFiat(
      value: value,
      from: from,
      to: to,
    );
  }

}