import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/features/data/services/wallet_service.dart';
import 'package:cryphoria_mobile/features/domain/entities/wallet.dart';
import 'package:cryphoria_mobile/features/data/data_sources/fake_transactions_data.dart';
import 'package:cryphoria_mobile/features/domain/usecases/EmployeeHome/employee_home_usecase.dart';

class HomeEmployeeState {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final bool isInitialized;
  final String employeeId;
  final String employeeName;
  final String employeeAvatar;
  final String nextPayoutDate;
  final String payoutFrequency;
  final List<Map<String, dynamic>> recentTransactions;
  final Wallet? wallet;
  final List<Map<String, dynamic>> transactions;
  final String selectedCurrency;

  const HomeEmployeeState({
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.isInitialized,
    required this.employeeId,
    required this.employeeName,
    required this.employeeAvatar,
    required this.nextPayoutDate,
    required this.payoutFrequency,
    required this.recentTransactions,
    required this.wallet,
    required this.transactions,
    required this.selectedCurrency,
  });

  factory HomeEmployeeState.initial() => const HomeEmployeeState(
        isLoading: false,
        hasError: false,
        errorMessage: '',
        isInitialized: false,
        employeeId: '',
        employeeName: 'Anna',
        employeeAvatar: '',
        nextPayoutDate: 'June 30, 2023',
        payoutFrequency: 'Monthly',
        recentTransactions: [],
        wallet: null,
        transactions: [],
        selectedCurrency: 'PHP',
      );

  bool get isLoaded => isInitialized && !isLoading && !hasError;
  bool get hasTransactions => recentTransactions.isNotEmpty;

  HomeEmployeeState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    bool? isInitialized,
    String? employeeId,
    String? employeeName,
    String? employeeAvatar,
    String? nextPayoutDate,
    String? payoutFrequency,
    List<Map<String, dynamic>>? recentTransactions,
    Wallet? wallet,
    List<Map<String, dynamic>>? transactions,
    String? selectedCurrency,
  }) {
    return HomeEmployeeState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      employeeAvatar: employeeAvatar ?? this.employeeAvatar,
      nextPayoutDate: nextPayoutDate ?? this.nextPayoutDate,
      payoutFrequency: payoutFrequency ?? this.payoutFrequency,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
    );
  }
}

class HomeEmployeeNotifier extends StateNotifier<HomeEmployeeState> {
  HomeEmployeeNotifier({
    required WalletService walletService,
    required FakeTransactionsDataSource transactionsDataSource,
    required GetEmployeeDashboardData getEmployeeDashboardData,
  })  : _walletService = walletService,
        _transactionsDataSource = transactionsDataSource,
        _getDashboardData = getEmployeeDashboardData,
        super(HomeEmployeeState.initial());

  final WalletService _walletService;
  final FakeTransactionsDataSource _transactionsDataSource;
  final GetEmployeeDashboardData _getDashboardData;

  Future<void> getDashboardData(String employeeId) async {
    _setLoading(true);
    state = state.copyWith(employeeId: employeeId);

    try {
      final dashboardData = await _getDashboardData(employeeId);
      
      // Update employee data
      state = state.copyWith(
        employeeName: dashboardData.employee.name,
        employeeAvatar: dashboardData.employee.avatarUrl,
        hasError: false,
        errorMessage: '',
      );
      
      // Update payout info
      final nextPayoutDate = _formatDate(dashboardData.payoutInfo.nextPayoutDate);
      state = state.copyWith(
        nextPayoutDate: nextPayoutDate,
        payoutFrequency: dashboardData.payoutInfo.frequency,
        hasError: false,
        errorMessage: '',
      );
      
      // Update recent transactions
      final updatedRecentTransactions = dashboardData.recentTransactions.map((transaction) => {
        'id': transaction.id,
        'date': _formatDate(transaction.date),
        'amount': '${transaction.amount} ${transaction.currency}',
        'usdAmount': '\$${transaction.usdAmount.toStringAsFixed(2)} USD',
        'status': transaction.status.name,
      }).toList();
      state = state.copyWith(
        recentTransactions: List.unmodifiable(updatedRecentTransactions),
        hasError: false,
        errorMessage: '',
      );
      
      // Load wallet data (keeping the existing wallet loading logic for now)
      await _loadInitialWalletData();
      
      state = state.copyWith(isInitialized: true);
      debugPrint('Dashboard data loaded, wallet: ${state.wallet?.toJson()}');
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load dashboard data: $e');
    }
  }

  Future<void> _loadEmployeeData(String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    switch (employeeId) {
      case 'anna_001':
        state = state.copyWith(
          employeeName: 'Anna Smith',
          hasError: false,
          errorMessage: '',
        );
        break;
      case 'john_002':
        state = state.copyWith(
          employeeName: 'John Doe',
          hasError: false,
          errorMessage: '',
        );
        break;
      case 'sarah_003':
        state = state.copyWith(
          employeeName: 'Sarah Johnson',
          hasError: false,
          errorMessage: '',
        );
        break;
      default:
        state = state.copyWith(
          employeeName: 'Anna',
          hasError: false,
          errorMessage: '',
        );
    }
    state = state.copyWith(employeeAvatar: '');
  }

  Future<void> _loadPayoutInfo(String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final now = DateTime.now();
    final nextPayout = DateTime(now.year, now.month + 1, 30);
    state = state.copyWith(
      nextPayoutDate: _formatDate(nextPayout),
      payoutFrequency: 'Monthly',
      hasError: false,
      errorMessage: '',
    );
  }

  Future<void> _loadRecentTransactions(String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final fallbackTransactions = [
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
    state = state.copyWith(
      recentTransactions: List.unmodifiable(fallbackTransactions),
      hasError: false,
      errorMessage: '',
    );
  }

  Future<void> _loadInitialWalletData() async {
    try {
      final transactions = _transactionsDataSource.getTransactions();
      state = state.copyWith(
        transactions: List.unmodifiable(transactions),
        hasError: false,
        errorMessage: '',
      );
      if (await _walletService.hasStoredWallet()) {
        debugPrint('Attempting to reconnect stored wallet');
        await reconnect();
      } else {
        debugPrint('No stored wallet found');
      }
      state = state.copyWith(errorMessage: '', hasError: false);
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Failed to load wallet data: $e',
      );
      debugPrint('Error in _loadInitialWalletData: $e');
    }
  }

  Future<void> connect(
      String privateKey, {
        required String endpoint,
        required String walletName,
        required String walletType,
      }) async {
    _setLoading(true);
    state = state.copyWith(errorMessage: '');
    try {
      final wallet = await _walletService.connectWallet(
        privateKey,
        endpoint: endpoint,
        walletName: walletName,
        walletType: walletType,
      );
      debugPrint('Connected wallet: ${wallet.toJson()}');
      state = state.copyWith(
        wallet: wallet,
        selectedCurrency: 'PHP',
        hasError: false,
        errorMessage: '',
      );

      /// ✅ Fetch fresh balance after connecting
      await fetchWalletBalance();
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Failed to connect wallet: $e',
      );
      debugPrint('Connection error: $e');
    } finally {
      _setLoading(false);
    }
  }


  Future<void> reconnect() async {
    _setLoading(true);
    state = state.copyWith(errorMessage: '');
    try {
      final wallet = await _walletService.reconnect();
      if (wallet != null) {
        debugPrint('Reconnected wallet: ${wallet.toJson()}');
        state = state.copyWith(
          wallet: wallet,
          selectedCurrency: 'PHP',
          hasError: false,
          errorMessage: '',
        );
        await fetchWalletBalance();
      }

    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Failed to reconnect wallet: $e',
      );
      debugPrint('Reconnect error: $e');
    } finally {
      _setLoading(false);
    }
  }


  Future<void> _fetchTransactions() async {
    try {
      final transactions = _transactionsDataSource.getTransactions();
      state = state.copyWith(
        transactions: List.unmodifiable(transactions),
        hasError: false,
        errorMessage: '',
      );
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Failed to fetch transactions: $e',
      );
    }
  }

  Future<void> refresh() async {
    _setLoading(true);
    state = state.copyWith(errorMessage: '', hasError: false);
    try {
      await _fetchTransactions();
      await refreshWallet();
      await _loadEmployeeData(state.employeeId);
      await _loadPayoutInfo(state.employeeId);
      await _loadRecentTransactions(state.employeeId);
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Failed to refresh data: $e',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> hasStoredWallet() async {
    try {
      final hasWallet = await _walletService.hasStoredWallet();
      debugPrint('Has stored wallet: $hasWallet');
      return hasWallet;
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Failed to check stored wallet: $e',
      );
      return false;
    }
  }

  /// ✅ ADD THIS NEW METHOD HERE
  Future<void> fetchWalletBalance() async {
    final wallet = state.wallet;
    if (wallet == null) return;

    _setLoading(true);

    try {
      final updatedWallet = await _walletService.refreshBalance(wallet);
      state = state.copyWith(
        wallet: updatedWallet,
        errorMessage: '',
        hasError: false,
      );
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Failed to fetch wallet balance: $e',
      );
      debugPrint('fetchWalletBalance error: $e');
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    state = state.copyWith(
      errorMessage: '',
      hasError: false,
    );
  }



  Future<void> refreshWallet() async {
    final wallet = state.wallet;
    if (wallet == null) {
      debugPrint('No wallet to refresh');
      return;
    }
    _setLoading(true);
    try {
      final refreshedWallet = await _walletService.reconnect();
      if (refreshedWallet != null) {
        state = state.copyWith(wallet: refreshedWallet);
        debugPrint('Refreshed wallet: ${refreshedWallet.toJson()}');
      }
      state = state.copyWith(errorMessage: '', hasError: false);
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Failed to refresh wallet: $e',
      );
      debugPrint('Refresh wallet error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> disconnectWallet() async {
    try {
      await _walletService.disconnect();
      state = state.copyWith(
        wallet: null,
        errorMessage: '',
        selectedCurrency: 'PHP',
        hasError: false,
      );
      debugPrint('Wallet disconnected');
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Failed to disconnect wallet: $e',
      );
    }
  }

  void changeCurrency(String currency) {
    if (state.selectedCurrency == currency || state.wallet == null) return;
    state = state.copyWith(selectedCurrency: currency);
  }

  Future<void> refreshData(String employeeId) async {
    await getDashboardData(employeeId);
  }

  Future<void> forceRefresh(String employeeId) async {
    state = state.copyWith(isInitialized: false);
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
    if (loading) {
      state = state.copyWith(
        isLoading: true,
        hasError: false,
        errorMessage: '',
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  void _setError(String error) {
    state = state.copyWith(
      isLoading: false,
      hasError: true,
      errorMessage: error,
    );
  }
}
