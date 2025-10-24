import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/features/data/services/wallet_service.dart';
import 'package:cryphoria_mobile/features/domain/entities/wallet.dart';
import 'package:cryphoria_mobile/features/data/data_sources/eth_transaction_data_source.dart';

class WalletState {
  final Wallet? wallet;
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> transactions;
  
  // Pagination fields for All Transactions screen
  final List<Map<String, dynamic>> allTransactions;
  final bool hasMoreTransactions;
  final int currentOffset;
  final bool isLoadingMore;

  const WalletState({
    required this.wallet,
    required this.isLoading,
    required this.error,
    required this.transactions,
    required this.allTransactions,
    required this.hasMoreTransactions,
    required this.currentOffset,
    required this.isLoadingMore,
  });

  factory WalletState.initial() => const WalletState(
        wallet: null,
        isLoading: false,
        error: null,
        transactions: [],
        allTransactions: [],
        hasMoreTransactions: true,
        currentOffset: 0,
        isLoadingMore: false,
      );

  WalletState copyWith({
    Wallet? Function()? wallet, // Use function to allow explicit null
    bool? isLoading,
    String? Function()? error, // Use function to allow explicit null
    List<Map<String, dynamic>>? transactions,
    List<Map<String, dynamic>>? allTransactions,
    bool? hasMoreTransactions,
    int? currentOffset,
    bool? isLoadingMore,
  }) {
    return WalletState(
      wallet: wallet != null ? wallet() : this.wallet,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      transactions: transactions ?? this.transactions,
      allTransactions: allTransactions ?? this.allTransactions,
      hasMoreTransactions: hasMoreTransactions ?? this.hasMoreTransactions,
      currentOffset: currentOffset ?? this.currentOffset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier({
    required WalletService walletService,
    required EthTransactionDataSource ethTransactionDataSource,
  })  : _walletService = walletService,
        _ethTransactionDataSource = ethTransactionDataSource,
        super(WalletState.initial()) {
    _loadInitialData();
  }

  final WalletService _walletService;
  final EthTransactionDataSource _ethTransactionDataSource;

  /// Loads initial data (e.g., transactions) and fetches user's connected wallet
  Future<void> _loadInitialData() async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      // Fetch user's connected wallet from backend
      final wallet = await _walletService.getUserWallet();
      if (wallet != null) {
        state = state.copyWith(wallet: () => wallet);
      }
      
      // Load transactions
      await _fetchTransactions();
      state = state.copyWith(error: () => null);
    } catch (e) {
      state = state.copyWith(error: () => e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Connects to a wallet with the provided private key
  Future<void> connect(
      String privateKey, {
        String? walletName,
        String? walletType,
      }) async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final wallet = await _walletService.connectWallet(
        privateKey,
        walletName: walletName ?? 'My Wallet',
        walletType: walletType ?? 'imported',
      );
      
      // Wallet connected successfully - fetch transactions now
      state = state.copyWith(wallet: () => wallet);
      await _fetchTransactions();
    } catch (e) {
      state = state.copyWith(error: () => e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Fetches user's connected wallet from backend
  Future<void> reconnect() async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      // Fetch user's connected wallet from backend
      final wallet = await _walletService.getUserWallet();
      if (wallet != null) {
        state = state.copyWith(wallet: () => wallet);
        // Fetch transactions for the wallet
        await _fetchTransactions();
      } else {
        state = state.copyWith(error: () => 'No connected wallet found. Please connect your wallet.');
      }
    } catch (e) {
      state = state.copyWith(error: () => e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Fetches transactions from the data source
  Future<void> _fetchTransactions() async {
    try {
      // Get user wallets for received transaction detection
      List<Wallet> userWallets = [];
      if (state.wallet != null) {
        userWallets = [state.wallet!];
      }
      
      // Get all transactions (sent + received)
      // The data source will now automatically find real transaction hashes to check
      final transactions = await _ethTransactionDataSource.getAllTransactions(
        userWallets: userWallets,
        knownReceivedHashes: null, // Let the data source find real hashes
        limit: 10,
      );
      
      state = state.copyWith(transactions: List.unmodifiable(transactions), error: () => null);
    } catch (e) {
      state = state.copyWith(error: () => e.toString(), transactions: const []);
      print('⚠️ Failed to fetch transactions: $e');
    }
  }

  /// Refreshes transaction data (e.g., on pull-to-refresh)
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      await _fetchTransactions();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Checks if a stored wallet exists (async to match WalletService)
  Future<bool> hasStoredWallet() async {
    try {
      return await _walletService.hasStoredWallet();
    } catch (e) {
      state = state.copyWith(error: () => e.toString());
      return false;
    }
  }

  /// Clears the current error state
  void clearError() {
    state = state.copyWith(error: () => null);
  }

  /// Refreshes the current wallet balance and PHP conversion
  Future<void> refreshWallet() async {
    if (state.wallet == null) {
      debugPrint('🔍 Manager - No wallet to refresh');
      return;
    }
    
    debugPrint('🔍 Manager - Refreshing wallet balance: ${state.wallet!.address}');
    state = state.copyWith(isLoading: true);
    
    try {
      // Only refresh balance without reconnecting (prevents full screen refresh)
      final refreshedWallet = await _walletService.refreshBalance(state.wallet!);
      
      // Check if the notifier is still mounted before updating state
      if (mounted) {
        state = state.copyWith(wallet: () => refreshedWallet);
        debugPrint('🔍 Manager - Refreshed wallet balance: ${refreshedWallet.toJson()}');
        state = state.copyWith(error: () => null);
      } else {
        debugPrint('🔍 Manager - Widget disposed, skipping state update');
      }
    } catch (e) {
      debugPrint('❌ Manager - Refresh wallet balance error: $e');
      
      // Check if the notifier is still mounted before updating state
      if (mounted) {
        state = state.copyWith(error: () => e.toString());
      } else {
        debugPrint('🔍 Manager - Widget disposed, skipping error state update');
      }
    } finally {
      // Check if the notifier is still mounted before updating loading state
      if (mounted) {
        state = state.copyWith(isLoading: false);
      } else {
        debugPrint('🔍 Manager - Widget disposed, skipping loading state update');
      }
    }
  }

  /// Disconnects the current wallet
  Future<void> disconnectWallet() async {
    debugPrint('🔍 Manager - Starting disconnect process');
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      if (state.wallet != null) {
        debugPrint('🔍 Manager - Disconnecting wallet: ${state.wallet!.address}');
        await _walletService.disconnect(state.wallet!);
        debugPrint('🔍 Manager - Wallet service disconnect completed');
      }
      
      // Force clear the wallet state
      debugPrint('🔍 Manager - Before state update, wallet is: ${state.wallet?.address}');
      state = state.copyWith(wallet: () => null, error: () => null);
      debugPrint('🔍 Manager - After state update, wallet is: ${state.wallet?.address}');
      debugPrint('🔍 Manager - State updated, notifying listeners');
    } catch (e) {
      debugPrint('❌ Manager - Disconnect error: $e');
      state = state.copyWith(error: () => e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
      debugPrint('🔍 Manager - Disconnect process completed');
    }
  }

  /// Switches wallet by first disconnecting current wallet, then allowing connection of new wallet
  Future<void> switchWallet() async {
    debugPrint('🔍 Manager - Starting switch wallet process');
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      // First disconnect the current wallet if one exists
      if (state.wallet != null) {
        debugPrint('🔍 Manager - Disconnecting current wallet: ${state.wallet!.address}');
        await _walletService.disconnect(state.wallet!);
        debugPrint('🔍 Manager - Current wallet disconnected');
      }
      
      // Clear the wallet state
      state = state.copyWith(wallet: () => null, error: () => null);
      debugPrint('🔍 Manager - Wallet state cleared, ready for new connection');
    } catch (e) {
      debugPrint('❌ Manager - Switch wallet error: $e');
      state = state.copyWith(error: () => e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
      debugPrint('🔍 Manager - Switch wallet process completed');
    }
  }
  
  /// Refreshes transaction data specifically
  Future<void> refreshTransactions() async {
    try {
      // Get user wallets for received transaction detection
      List<Wallet> userWallets = [];
      if (state.wallet != null) {
        userWallets = [state.wallet!];
      }
      
      final transactions = await _ethTransactionDataSource.getAllTransactions(
        userWallets: userWallets,
        knownReceivedHashes: null, // Let the data source find real hashes
        limit: 10,
      );
      state = state.copyWith(transactions: List.unmodifiable(transactions));
    } catch (e) {
      print('⚠️ Failed to refresh transactions: $e');
      // Keep existing transactions on error
    }
  }

  /// Fetches all transactions for the All Transactions screen with pagination
  Future<void> fetchAllTransactions({int limit = 20, int offset = 0}) async {
    try {
      // Get user wallets for received transaction detection
      List<Wallet> userWallets = [];
      if (state.wallet != null) {
        userWallets = [state.wallet!];
      }
      
      final transactions = await _ethTransactionDataSource.getAllTransactions(
        userWallets: userWallets,
        knownReceivedHashes: null,
        limit: limit,
        offset: offset,
      );
      
      // If this is the first page (offset = 0), replace all transactions
      // Otherwise, append to existing transactions
      final updatedTransactions = offset == 0 
          ? List<Map<String, dynamic>>.unmodifiable(transactions)
          : List<Map<String, dynamic>>.unmodifiable([...state.allTransactions, ...transactions]);
      
      // Check if we have more transactions (if we got less than requested, we're at the end)
      final hasMore = transactions.length >= limit;
      
      state = state.copyWith(
        allTransactions: updatedTransactions,
        hasMoreTransactions: hasMore,
        currentOffset: offset + transactions.length,
        isLoadingMore: false,
      );
    } catch (e) {
      print('⚠️ Failed to fetch all transactions: $e');
      state = state.copyWith(
        isLoadingMore: false,
        error: () => e.toString(),
      );
    }
  }

  /// Loads more transactions for pagination
  Future<void> loadMoreTransactions() async {
    if (state.isLoadingMore || !state.hasMoreTransactions) {
      return;
    }
    
    state = state.copyWith(isLoadingMore: true);
    await fetchAllTransactions(
      limit: 20,
      offset: state.currentOffset,
    );
  }

  /// Resets the all transactions pagination state
  void resetAllTransactions() {
    state = state.copyWith(
      allTransactions: [],
      hasMoreTransactions: true,
      currentOffset: 0,
      isLoadingMore: false,
    );
  }
}
