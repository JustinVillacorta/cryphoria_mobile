import 'package:flutter/cupertino.dart';

import '../data_sources/walletRemoteDataSource.dart';
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
    // Derive address from private key for validation
    final creds = EthPrivateKey.fromHex(privateKey);
    final address = creds.address.hexEip55;

    // Connect wallet to backend - private key will be encrypted and stored on backend
    final walletData = await remoteDataSource.connectWallet(
      privateKey: privateKey,
      walletName: walletName,
      walletType: walletType,
    );

    // Get balance from wallet balance endpoint
    double balance = 0.0;
    try {
      final walletData = await remoteDataSource.getWalletBalance();
      balance = (walletData['balance_eth'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      debugPrint('WalletService.connectWallet: getWalletBalance failed: $e');
      balance = 0.0;
    }

    // Convert ETH balance to both PHP and USD
    final rates = await currencyService.getETHRates();
    final balanceInPHP = balance * (rates['php'] ?? 0.0);
    final balanceInUSD = balance * (rates['usd'] ?? 0.0);
    
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
      // Check if user has a connected wallet
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
      // Still allow local disconnect even if backend call fails
    }
  }

  Future<Wallet?> getUserWallet() async {
    try {
      // Get wallet balance which includes wallet information
      final walletData = await remoteDataSource.getWalletBalance();
      
      debugPrint('🔍 getUserWallet - Backend response: $walletData');
      
      // Check if the response indicates no wallet is connected
      if (walletData.isEmpty) {
        debugPrint('🔍 getUserWallet - Empty response, no wallet connected');
        return null;
      }
      
      final walletAddress = walletData['wallet_address']?.toString();
      final balanceEth = (walletData['balance_eth'] as num?)?.toDouble() ?? 0.0;
      
      debugPrint('🔍 getUserWallet - walletAddress: $walletAddress, balanceEth: $balanceEth');
      
      // Check for various conditions that indicate no wallet is connected
      if (walletAddress == null || 
          walletAddress.isEmpty || 
          walletAddress == 'null' ||
          walletAddress == 'None' ||
          balanceEth == 0.0) {
        debugPrint('🔍 getUserWallet - No valid wallet data found, returning null');
        return null; // No wallet connected
      }
      
      // Convert ETH balance to both PHP and USD
      final rates = await currencyService.getETHRates();
      final balanceInPHP = balanceEth * (rates['php'] ?? 0.0);
      final balanceInUSD = balanceEth * (rates['usd'] ?? 0.0);
      
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
    // Get user's single connected wallet
    return await getUserWallet();
  }

  Future<Wallet> refreshBalance(Wallet wallet) async {
    if (wallet.address.isEmpty) {
      throw Exception('Cannot refresh balance: wallet address is empty');
    }

    try {
      // Get wallet balance data which includes the current balance
      final walletData = await remoteDataSource.getWalletBalance();
      final balanceEth = (walletData['balance_eth'] as num?)?.toDouble() ?? 0.0;
      
      final rates = await currencyService.getETHRates();
      final balanceInPHP = balanceEth * (rates['php'] ?? 0.0);
      final balanceInUSD = balanceEth * (rates['usd'] ?? 0.0);

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
  }) async {
    return await remoteDataSource.sendEth(
      toAddress: toAddress,
      amount: amount,
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      company: company,
      category: category,
      description: description,
    );
  }

}
