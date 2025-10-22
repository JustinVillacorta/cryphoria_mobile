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
        employeeName: '',
        employeeAvatar: '',
        nextPayoutDate: '',
        payoutFrequency: '',
        recentTransactions: [],
        wallet: null,
        transactions: [],
        selectedCurrency: '',
      );

  bool get isLoaded => isInitialized && !isLoading && !hasError;
  bool get hasTransactions => recentTransactions.isNotEmpty;

  HomeEmployeeState copyWith({
    bool? isLoading,
    bool? hasError,
    String? Function()? errorMessage, // Use function to allow explicit null
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
      errorMessage: errorMessage != null ? (errorMessage() ?? '') : this.errorMessage,
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
    required TransactionsDataSource transactionsDataSource,
    required GetEmployeeDashboardData getEmployeeDashboardData,
  })  : _walletService = walletService,
        _transactionsDataSource = transactionsDataSource,
        _getDashboardData = getEmployeeDashboardData,
        super(HomeEmployeeState.initial());

  final WalletService _walletService;
  final TransactionsDataSource _transactionsDataSource;
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
        errorMessage: () => '',
      );
      
      // Update payout info
      final nextPayoutDate = _formatDate(dashboardData.payoutInfo.nextPayoutDate);
      state = state.copyWith(
        nextPayoutDate: nextPayoutDate,
        payoutFrequency: dashboardData.payoutInfo.frequency,
        hasError: false,
        errorMessage: () => '',
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
        errorMessage: () => '',
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

  // Removed fake data loading methods as we now use real data from getDashboardData

  Future<void> _loadInitialWalletData() async {
    try {
      // Fetch user's connected wallet from backend
      final wallet = await _walletService.getUserWallet();
      if (wallet != null) {
        state = state.copyWith(wallet: wallet);
      }
      
      final transactions = await _transactionsDataSource.getRecentTransactions(limit: 10);
      state = state.copyWith(
        transactions: List.unmodifiable(transactions),
        hasError: false,
        errorMessage: () => '',
      );
      
      debugPrint('Loaded connected wallet from backend: ${wallet?.address ?? 'None'}');
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: () => 'Failed to load wallet data: $e',
      );
      debugPrint('Error in _loadInitialWalletData: $e');
    }
  }

  Future<void> connect(
      String privateKey, {
        required String walletName,
        required String walletType,
      }) async {
    _setLoading(true);
    state = state.copyWith(errorMessage: () => '');
    try {
      final wallet = await _walletService.connectWallet(
        privateKey,
        walletName: walletName,
        walletType: walletType,
      );
      debugPrint('Connected wallet: ${wallet.toJson()}');
      state = state.copyWith(
        wallet: wallet,
        selectedCurrency: 'PHP',
        hasError: false,
        errorMessage: () => '',
      );

      /// ✅ Fetch fresh balance after connecting
      await fetchWalletBalance();
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: () => 'Failed to connect wallet: $e',
      );
      debugPrint('Connection error: $e');
    } finally {
      _setLoading(false);
    }
  }


  Future<void> reconnect() async {
    _setLoading(true);
    state = state.copyWith(errorMessage: () => '');
    try {
      // Fetch user's connected wallet from backend
      final wallet = await _walletService.getUserWallet();
      if (wallet != null) {
        debugPrint('Fetched wallet from backend: ${wallet.toJson()}');
        state = state.copyWith(
          wallet: wallet,
          selectedCurrency: 'PHP',
          hasError: false,
          errorMessage: () => '',
        );
        await fetchWalletBalance();
      } else {
        state = state.copyWith(
          hasError: true,
          errorMessage: () => 'No connected wallet found. Please connect your wallet.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: () => 'Failed to fetch wallet: $e',
      );
      debugPrint('Reconnect error: $e');
    } finally {
      _setLoading(false);
    }
  }


  Future<void> _fetchTransactions() async {
    try {
      final transactions = await _transactionsDataSource.getRecentTransactions(limit: 10);
      state = state.copyWith(
        transactions: List.unmodifiable(transactions),
        hasError: false,
        errorMessage: () => '',
      );
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: () => 'Failed to fetch transactions: $e',
      );
    }
  }

  Future<void> refresh() async {
    _setLoading(true);
    state = state.copyWith(errorMessage: () => '', hasError: false);
    try {
      await _fetchTransactions();
      await refreshWallet();
      await getDashboardData(state.employeeId);
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: () => 'Failed to refresh data: $e',
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
        errorMessage: () => 'Failed to check stored wallet: $e',
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
        errorMessage: () => '',
        hasError: false,
      );
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: () => 'Failed to fetch wallet balance: $e',
      );
      debugPrint('fetchWalletBalance error: $e');
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    state = state.copyWith(
      errorMessage: () => '',
      hasError: false,
    );
  }



  Future<void> refreshWallet() async {
    final wallet = state.wallet;
    if (wallet == null) {
      debugPrint('🔍 Employee - No wallet to refresh');
      return;
    }
    
    debugPrint('🔍 Employee - Refreshing wallet: ${wallet.address}');
    _setLoading(true);
    try {
      final refreshedWallet = await _walletService.reconnect();
      if (refreshedWallet != null) {
        state = state.copyWith(wallet: refreshedWallet);
        debugPrint('🔍 Employee - Refreshed wallet: ${refreshedWallet.toJson()}');
      } else {
        debugPrint('🔍 Employee - No wallet returned from refresh, clearing state');
        state = state.copyWith(wallet: null);
      }
      state = state.copyWith(errorMessage: () => '', hasError: false);
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: () => 'Failed to refresh wallet: $e',
      );
      debugPrint('❌ Employee - Refresh wallet error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> disconnectWallet() async {
    debugPrint('🔍 Employee - Starting disconnect process');
    _setLoading(true);
    try {
      if (state.wallet != null) {
        debugPrint('🔍 Employee - Disconnecting wallet: ${state.wallet!.address}');
        await _walletService.disconnect(state.wallet!);
        debugPrint('🔍 Employee - Wallet service disconnect completed');
      }
      
      // Force clear the wallet state
      debugPrint('🔍 Employee - Before state update, wallet is: ${state.wallet?.address}');
      state = state.copyWith(
        wallet: null,
        errorMessage: () => '',
        selectedCurrency: 'PHP',
        hasError: false,
      );
      debugPrint('🔍 Employee - After state update, wallet is: ${state.wallet?.address}');
      debugPrint('🔍 Employee - State updated, notifying listeners');
    } catch (e) {
      debugPrint('❌ Employee - Disconnect error: $e');
      state = state.copyWith(
        hasError: true,
        errorMessage: () => 'Failed to disconnect wallet: $e',
      );
    } finally {
      _setLoading(false);
      debugPrint('🔍 Employee - Disconnect process completed');
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
        errorMessage: () => '',
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  void _setError(String error) {
    state = state.copyWith(
      isLoading: false,
      hasError: true,
      errorMessage: () => error,
    );
  }
}
