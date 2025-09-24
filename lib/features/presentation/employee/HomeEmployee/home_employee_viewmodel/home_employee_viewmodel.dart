import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/data/services/wallet_service.dart';
import 'package:cryphoria_mobile/features/domain/entities/wallet.dart';
import 'package:cryphoria_mobile/features/data/data_sources/fake_transactions_data.dart';
import 'package:cryphoria_mobile/features/domain/usecases/EmployeeHome/employee_home_usecase.dart';
import 'package:cryphoria_mobile/dependency_injection/di.dart';

class HomeEmployeeViewModel extends ChangeNotifier {
  final WalletService walletService = sl<WalletService>();
  final FakeTransactionsDataSource _transactionsDataSource = sl<FakeTransactionsDataSource>();
  final GetEmployeeDashboardData _getDashboardData = sl<GetEmployeeDashboardData>();

  // State management
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isInitialized = false;

  // Employee data
  String _employeeId = '';
  String _employeeName = 'Anna';
  String _employeeAvatar = '';

  // Payout info
  String _nextPayoutDate = 'June 30, 2023';
  String _payoutFrequency = 'Monthly';

  // Transactions
  List<Map<String, dynamic>> _recentTransactions = [];

  // Wallet state
  Wallet? _wallet;
  List<Map<String, dynamic>> _transactions = [];
  String _selectedCurrency = 'PHP';

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get isLoaded => _isInitialized && !_isLoading && !_hasError;
  String get employeeId => _employeeId;
  String get employeeName => _employeeName;
  String get employeeAvatar => _employeeAvatar;
  String get nextPayoutDate => _nextPayoutDate;
  String get payoutFrequency => _payoutFrequency;
  List<Map<String, dynamic>> get recentTransactions => _recentTransactions;
  Wallet? get wallet => _wallet;
  String? get error => _errorMessage;
  List<Map<String, dynamic>> get transactions => List.unmodifiable(_transactions);
  String get selectedCurrency => _selectedCurrency;
  bool get hasTransactions => _recentTransactions.isNotEmpty;

  Future<void> getDashboardData(String employeeId) async {
    _employeeId = employeeId;
    _setLoading(true);

    try {
      final dashboardData = await _getDashboardData(employeeId);
      
      // Update employee data
      _employeeName = dashboardData.employee.name;
      _employeeAvatar = dashboardData.employee.avatarUrl;
      
      // Update payout info
      _nextPayoutDate = _formatDate(dashboardData.payoutInfo.nextPayoutDate);
      _payoutFrequency = dashboardData.payoutInfo.frequency;
      
      // Update recent transactions
      _recentTransactions = dashboardData.recentTransactions.map((transaction) => {
        'id': transaction.id,
        'date': _formatDate(transaction.date),
        'amount': '${transaction.amount} ${transaction.currency}',
        'usdAmount': '\$${transaction.usdAmount.toStringAsFixed(2)} USD',
        'status': transaction.status.name,
      }).toList();
      
      // Load wallet data (keeping the existing wallet loading logic for now)
      await _loadInitialWalletData();
      
      _isInitialized = true;
      debugPrint('Dashboard data loaded, wallet: ${_wallet?.toJson()}');
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load dashboard data: $e');
    }
  }

  Future<void> _loadEmployeeData(String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    switch (employeeId) {
      case 'anna_001':
        _employeeName = 'Anna Smith';
        break;
      case 'john_002':
        _employeeName = 'John Doe';
        break;
      case 'sarah_003':
        _employeeName = 'Sarah Johnson';
        break;
      default:
        _employeeName = 'Anna';
    }
    _employeeAvatar = '';
  }

  Future<void> _loadPayoutInfo(String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final now = DateTime.now();
    final nextPayout = DateTime(now.year, now.month + 1, 30);
    _nextPayoutDate = _formatDate(nextPayout);
    _payoutFrequency = 'Monthly';
  }

  Future<void> _loadRecentTransactions(String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _recentTransactions = [
      {
        'id': '0xABC...123',
        'date': 'May 31, 2023',
        'amount': '0.45 ETH',
        'usdAmount': '\$820.90 USD',
        'status': 'Paid',
        'statusColor': Colors.green,
        'statusIcon': Icons.check_circle,
        'rawDate': DateTime(2023, 5, 31),
        'rawAmount': 0.45,
        'rawUsdAmount': 820.90,
      },
    ];
  }

  Future<void> _loadInitialWalletData() async {
    try {
      _transactions = _transactionsDataSource.getTransactions();
      if (await walletService.hasStoredWallet()) {
        debugPrint('Attempting to reconnect stored wallet');
        await reconnect();
      } else {
        debugPrint('No stored wallet found');
      }
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to load wallet data: $e';
      debugPrint('Error in _loadInitialWalletData: $e');
    }
    notifyListeners();
  }

  Future<void> connect(
      String privateKey, {
        required String endpoint,
        required String walletName,
        required String walletType,
      }) async {
    _setLoading(true);
    _errorMessage = '';
    notifyListeners();
    try {
      _wallet = await walletService.connectWallet(
        privateKey,
        endpoint: endpoint,
        walletName: walletName,
        walletType: walletType,
      );
      debugPrint('Connected wallet: ${_wallet?.toJson()}');
      _selectedCurrency = 'PHP';

      /// ✅ Fetch fresh balance after connecting
      await fetchWalletBalance();
    } catch (e) {
      _errorMessage = 'Failed to connect wallet: $e';
      debugPrint('Connection error: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }


  Future<void> reconnect() async {
    _setLoading(true);
    _errorMessage = '';
    notifyListeners();
    try {
      _wallet = await walletService.reconnect();
      debugPrint('Reconnected wallet: ${_wallet?.toJson()}');
      _selectedCurrency = 'PHP';

      /// Fetch fresh balance after reconnecting
      await fetchWalletBalance();
    } catch (e) {
      _errorMessage = 'Failed to reconnect wallet: $e';
      debugPrint('Reconnect error: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }


  Future<void> _fetchTransactions() async {
    try {
      _transactions = _transactionsDataSource.getTransactions();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to fetch transactions: $e';
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    _setLoading(true);
    _errorMessage = '';
    notifyListeners();
    try {
      await _fetchTransactions();
      await refreshWallet();
      await _loadEmployeeData(_employeeId);
      await _loadPayoutInfo(_employeeId);
      await _loadRecentTransactions(_employeeId);
    } catch (e) {
      _errorMessage = 'Failed to refresh data: $e';
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> hasStoredWallet() async {
    try {
      final hasWallet = await walletService.hasStoredWallet();
      debugPrint('Has stored wallet: $hasWallet');
      return hasWallet;
    } catch (e) {
      _errorMessage = 'Failed to check stored wallet: $e';
      notifyListeners();
      return false;
    }
  }

  /// ✅ ADD THIS NEW METHOD HERE
  Future<void> fetchWalletBalance() async {
    if (_wallet == null) return;

    _setLoading(true);
    notifyListeners();

    try {
      _wallet = await walletService.refreshBalance(_wallet!);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to fetch wallet balance: $e';
      debugPrint('fetchWalletBalance error: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    _hasError = false;
    notifyListeners();
  }



  Future<void> refreshWallet() async {
    if (_wallet == null) {
      debugPrint('No wallet to refresh');
      return;
    }
    _setLoading(true);
    notifyListeners();
    try {
      final refreshedWallet = await walletService.reconnect();
      if (refreshedWallet != null) {
        _wallet = refreshedWallet;
        debugPrint('Refreshed wallet: ${_wallet?.toJson()}');
      }
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to refresh wallet: $e';
      debugPrint('Refresh wallet error: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> disconnectWallet() async {
    try {
      await walletService.disconnect();
      _wallet = null;
      _errorMessage = '';
      _selectedCurrency = 'PHP';
      debugPrint('Wallet disconnected');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to disconnect wallet: $e';
      notifyListeners();
    }
  }

  void changeCurrency(String currency) {
    if (_selectedCurrency == currency || _wallet == null) return;
    _selectedCurrency = currency;
    notifyListeners();
  }

  Future<void> refreshData(String employeeId) async {
    await getDashboardData(employeeId);
  }

  Future<void> forceRefresh(String employeeId) async {
    _isInitialized = false;
    await getDashboardData(employeeId);
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _hasError = false;
      _errorMessage = '';
    }
    notifyListeners();
  }

  void _setError(String error) {
    _isLoading = false;
    _hasError = true;
    _errorMessage = error;
    notifyListeners();
  }
}