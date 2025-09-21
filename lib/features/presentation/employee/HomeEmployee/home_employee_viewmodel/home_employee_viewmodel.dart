// lib/features/presentation/employee/home/viewmodel/home_employee_viewmodel.dart
import 'package:flutter/material.dart';

class HomeEmployeeViewModel extends ChangeNotifier {

  // State management
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isInitialized = false;

  // Employee data
  String _employeeId = '';
  String _employeeName = 'Anna';
  String _employeeAvatar = '';

  // Wallet data
  String _walletCurrency = 'ETH';
  double _walletBalance = 67980.0;
  double _convertedAmount = 12230.0;
  String _convertedCurrency = 'PHP';

  // Payout info
  String _nextPayoutDate = 'June 30, 2023';
  String _payoutFrequency = 'Monthly';

  // Transactions
  List<Map<String, dynamic>> _recentTransactions = [];

  // Getters for state
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get isLoaded => _isInitialized && !_isLoading && !_hasError;

  // Getters for employee data
  String get employeeId => _employeeId;
  String get employeeName => _employeeName;
  String get employeeAvatar => _employeeAvatar;

  // Getters for wallet data
  String get walletCurrency => _walletCurrency;
  double get walletBalance => _walletBalance;
  double get convertedAmount => _convertedAmount;
  String get convertedCurrency => _convertedCurrency;

  // Getters for payout info
  String get nextPayoutDate => _nextPayoutDate;
  String get payoutFrequency => _payoutFrequency;

  // Getters for transactions
  List<Map<String, dynamic>> get recentTransactions => _recentTransactions;

  // Computed properties
  String get walletBalanceFormatted =>
      '${_walletBalance.toStringAsFixed(0)} $_walletCurrency';

  String get convertedBalanceFormatted =>
      '${_convertedAmount.toStringAsFixed(0)} $_convertedCurrency';

  String get walletDisplayBalance => '67,980 ETH'; // Formatted for display
  String get convertedDisplayBalance => '12,230 PHP'; // Formatted for display

  bool get hasTransactions => _recentTransactions.isNotEmpty;

  // Main method to load dashboard data
  Future<void> getDashboardData(String employeeId) async {
    _employeeId = employeeId;
    _setLoading(true);

    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 1200));

      // Simulate potential random error (10% chance)
      if (DateTime.now().millisecond % 10 == 0) {
        throw Exception('Network error occurred');
      }

      // Load employee data
      await _loadEmployeeData(employeeId);

      // Load wallet data
      await _loadWalletData(employeeId);

      // Load payout info
      await _loadPayoutInfo(employeeId);

      // Load recent transactions
      await _loadRecentTransactions(employeeId);

      _isInitialized = true;
      _setLoading(false);

    } catch (e) {
      _setError('Failed to load dashboard data: ${e.toString()}');
    }
  }

  // Load employee information
  Future<void> _loadEmployeeData(String employeeId) async {
    // Mock API call
    await Future.delayed(const Duration(milliseconds: 200));

    // Simulate different employees
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

    _employeeAvatar = ''; // Could be loaded from API
  }

  // Load wallet information
  Future<void> _loadWalletData(String employeeId) async {
    // Mock API call
    await Future.delayed(const Duration(milliseconds: 150));

    // Simulate different wallet balances
    _walletCurrency = 'ETH';
    _walletBalance = 67980.0 + (DateTime.now().millisecond % 1000); // Add some variation
    _convertedAmount = 12230.0 + (DateTime.now().millisecond % 500); // Add some variation
    _convertedCurrency = 'PHP';
  }

  // Load payout information
  Future<void> _loadPayoutInfo(String employeeId) async {
    // Mock API call
    await Future.delayed(const Duration(milliseconds: 100));

    final now = DateTime.now();
    final nextPayout = DateTime(now.year, now.month + 1, 30);

    _nextPayoutDate = _formatDate(nextPayout);
    _payoutFrequency = 'Monthly';
  }

  // Load recent transactions
  Future<void> _loadRecentTransactions(String employeeId) async {
    // Mock API call
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
      {
        'id': '0xABC...123',
        'date': 'April 30, 2023',
        'amount': '0.45 ETH',
        'usdAmount': '\$820.90 USD',
        'status': 'Paid',
        'statusColor': Colors.green,
        'statusIcon': Icons.check_circle,
        'rawDate': DateTime(2023, 4, 30),
        'rawAmount': 0.45,
        'rawUsdAmount': 820.90,
      },
      {
        'id': '0xABC...123',
        'date': 'March 31, 2023',
        'amount': '0.45 ETH',
        'usdAmount': '\$820.90 USD',
        'status': 'Paid',
        'statusColor': Colors.green,
        'statusIcon': Icons.check_circle,
        'rawDate': DateTime(2023, 3, 31),
        'rawAmount': 0.45,
        'rawUsdAmount': 820.90,
      },
      {
        'id': '0xABC...123',
        'date': 'June 30, 2023',
        'amount': '0.45 ETH',
        'usdAmount': '\$820.90 USD',
        'status': 'Pending',
        'statusColor': Colors.orange,
        'statusIcon': Icons.schedule,
        'rawDate': DateTime(2023, 6, 30),
        'rawAmount': 0.45,
        'rawUsdAmount': 820.90,
      },
      {
        'id': '0xABC...123',
        'date': 'July 30, 2023',
        'amount': '0.45 ETH',
        'usdAmount': '\$820.90 USD',
        'status': 'Pending',
        'statusColor': Colors.orange,
        'statusIcon': Icons.schedule,
        'rawDate': DateTime(2023, 7, 30),
        'rawAmount': 0.45,
        'rawUsdAmount': 820.90,
      },
    ];
  }

  // Refresh all data
  Future<void> refreshData(String employeeId) async {
    await getDashboardData(employeeId);
  }

  // Force refresh (pull to refresh)
  Future<void> forceRefresh(String employeeId) async {
    _isInitialized = false; // Force re-initialization
    await getDashboardData(employeeId);
  }

  // Event handlers
  void onNotificationTapped() {
    // Handle notification tap
    // You can add navigation logic here or emit events
    debugPrint('Notification tapped');
  }

  void onTransactionTapped(Map<String, dynamic> transaction) {
    // Handle transaction tap
    debugPrint('Transaction tapped: ${transaction['id']}');
  }

  void onViewAllTransactionsTapped() {
    // Handle view all transactions tap
    debugPrint('View all transactions tapped');
  }

  void onWalletConnectTapped() {
    // Handle wallet connect tap
    debugPrint('Connect wallet tapped');
  }

  // Utility methods
  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // State management helpers
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

  void clearError() {
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }

  // Helper methods for transaction filtering/sorting
  List<Map<String, dynamic>> getPaidTransactions() {
    return _recentTransactions
        .where((transaction) => transaction['status'] == 'Paid')
        .toList();
  }

  List<Map<String, dynamic>> getPendingTransactions() {
    return _recentTransactions
        .where((transaction) => transaction['status'] == 'Pending')
        .toList();
  }

  double getTotalEarnings() {
    return _recentTransactions
        .where((transaction) => transaction['status'] == 'Paid')
        .fold(0.0, (total, transaction) => total + transaction['rawAmount']);
  }

  double getPendingAmount() {
    return _recentTransactions
        .where((transaction) => transaction['status'] == 'Pending')
        .fold(0.0, (total, transaction) => total + transaction['rawAmount']);
  }

  // Reset method (useful for logout or user switching)
  void reset() {
    _isLoading = false;
    _hasError = false;
    _errorMessage = '';
    _isInitialized = false;
    _employeeId = '';
    _employeeName = 'Employee';
    _employeeAvatar = '';
    _walletCurrency = 'ETH';
    _walletBalance = 0.0;
    _convertedAmount = 0.0;
    _convertedCurrency = 'PHP';
    _nextPayoutDate = 'N/A';
    _payoutFrequency = 'Monthly';
    _recentTransactions = [];
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}