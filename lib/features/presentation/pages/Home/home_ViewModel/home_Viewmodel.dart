import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/data/services/wallet_service.dart';
import 'package:cryphoria_mobile/features/data/services/eth_payment_service.dart';
import 'package:cryphoria_mobile/features/domain/entities/wallet.dart';
import 'package:cryphoria_mobile/features/data/data_sources/eth_transaction_data_source.dart';
import 'package:cryphoria_mobile/dependency_injection/di.dart';

class WalletViewModel extends ChangeNotifier {
  // Dependencies
  final WalletService walletService;
  final EthTransactionDataSource _ethTransactionDataSource;
  late EthPaymentService _ethPaymentService;

  // State
  Wallet? _wallet;
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _transactions = [];

  // Getters
  Wallet? get wallet => _wallet;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get transactions => List.unmodifiable(_transactions);

  WalletViewModel({
    required this.walletService,
    EthTransactionDataSource? ethTransactionDataSource,
  }) : _ethTransactionDataSource = ethTransactionDataSource ?? sl<EthTransactionDataSource>() {
    try {
      _ethPaymentService = sl<EthPaymentService>();
    } catch (e) {
      print('⚠️ EthPaymentService not available in ViewModel: $e');
    }
    _loadInitialData();
  }

  /// Loads initial data (e.g., transactions) and checks for stored wallet on initialization
  Future<void> _loadInitialData() async {
    _isLoading = true;
    notifyListeners();
    try {
      // First check for stored wallet and reconnect
      if (await walletService.hasStoredWallet()) {
        await reconnect();
      }
      
      // Then load transactions (now that wallet is connected if it was stored)
      await _fetchTransactions();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Connects to a wallet with the provided private key
  Future<void> connect(
      String privateKey, {
        String? endpoint,
        String? walletName,
        String? walletType,
      }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _wallet = await walletService.connectWallet(
        privateKey,
        endpoint: endpoint ?? 'http://localhost:8545',
        walletName: walletName ?? 'My Wallet',
        walletType: walletType ?? 'imported',
      );
      
      // Wallet connected successfully - fetch transactions now
      await _fetchTransactions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reconnects to a previously stored wallet
  Future<void> reconnect() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _wallet = await walletService.reconnect();
      
      // Wallet reconnected successfully - fetch transactions now
      await _fetchTransactions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches transactions from the data source
  Future<void> _fetchTransactions() async {
    try {
      // Get user wallets for received transaction detection
      List<Wallet> userWallets = [];
      if (_wallet != null) {
        userWallets = [_wallet!];
      }
      
      // Get all transactions (sent + received)
      // The data source will now automatically find real transaction hashes to check
      _transactions = await _ethTransactionDataSource.getAllTransactions(
        userWallets: userWallets,
        knownReceivedHashes: null, // Let the data source find real hashes
        limit: 10,
      );
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('⚠️ Failed to fetch transactions: $e');
      _transactions = []; // Clear transactions on error
    }
    notifyListeners();
  }

  /// Refreshes transaction data (e.g., on pull-to-refresh)
  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _fetchTransactions();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Checks if a stored wallet exists (async to match WalletService)
  Future<bool> hasStoredWallet() async {
    try {
      return await walletService.hasStoredWallet();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clears the current error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refreshes the current wallet balance and PHP conversion
  Future<void> refreshWallet() async {
    if (_wallet == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Reconnect to refresh balance and conversion
      final refreshedWallet = await walletService.reconnect();
      if (refreshedWallet != null) {
        _wallet = refreshedWallet;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Disconnects the current wallet
  Future<void> disconnectWallet() async {
    try {
      await walletService.disconnect();
      _wallet = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Refreshes transaction data specifically
  Future<void> refreshTransactions() async {
    try {
      // Get user wallets for received transaction detection
      List<Wallet> userWallets = [];
      if (_wallet != null) {
        userWallets = [_wallet!];
      }
      
      _transactions = await _ethTransactionDataSource.getAllTransactions(
        userWallets: userWallets,
        knownReceivedHashes: null, // Let the data source find real hashes
        limit: 10,
      );
      notifyListeners();
    } catch (e) {
      print('⚠️ Failed to refresh transactions: $e');
      // Keep existing transactions on error
    }
  }
}