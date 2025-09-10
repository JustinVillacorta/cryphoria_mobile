import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/data/services/wallet_service.dart';
import 'package:cryphoria_mobile/features/domain/entities/wallet.dart';
import 'package:cryphoria_mobile/features/data/data_sources/fake_transactions_data.dart';
import 'package:cryphoria_mobile/dependency_injection/di.dart';

class WalletViewModel extends ChangeNotifier {
  // Dependencies
  final WalletService walletService;
  final FakeTransactionsDataSource _transactionsDataSource;

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
    FakeTransactionsDataSource? transactionsDataSource,
  }) : _transactionsDataSource = transactionsDataSource ?? sl<FakeTransactionsDataSource>() {
    _loadInitialData();
  }

  /// Loads initial data (e.g., transactions) and checks for stored wallet on initialization
  Future<void> _loadInitialData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _transactions = _transactionsDataSource.getTransactions();
      if (await walletService.hasStoredWallet()) {
        await reconnect();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Connects to a wallet using a private key and specified endpoint
  Future<void> connect(
      String privateKey, {
        required String endpoint,
        required String walletName,
        required String walletType,
      }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _wallet = await walletService.connectWallet(
        privateKey,
        endpoint: endpoint,
        walletName: walletName,
        walletType: walletType,
      );
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
      _transactions = _transactionsDataSource.getTransactions();
      _error = null;
    } catch (e) {
      _error = e.toString();
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

  /// Clears error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}