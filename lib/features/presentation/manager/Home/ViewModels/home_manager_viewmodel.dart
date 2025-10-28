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
    Wallet? Function()? wallet,
    bool? isLoading,
    String? Function()? error,
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

  Future<void> _loadInitialData() async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final wallet = await _walletService.getUserWallet();
      if (wallet != null) {
        state = state.copyWith(wallet: () => wallet);
      }

      await _fetchTransactions();
      state = state.copyWith(error: () => null);
    } catch (e) {
      state = state.copyWith(error: () => e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

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

      state = state.copyWith(wallet: () => wallet);
      await _fetchTransactions();
    } catch (e) {
      state = state.copyWith(error: () => e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> reconnect() async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final wallet = await _walletService.getUserWallet();
      if (wallet != null) {
        state = state.copyWith(wallet: () => wallet);
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

  Future<void> _fetchTransactions() async {
    try {
      List<Wallet> userWallets = [];
      if (state.wallet != null) {
        userWallets = [state.wallet!];
      }

      final transactions = await _ethTransactionDataSource.getAllTransactions(
        userWallets: userWallets,
        knownReceivedHashes: null,
        limit: 10,
      );

      state = state.copyWith(transactions: List.unmodifiable(transactions), error: () => null);
    } catch (e) {
      state = state.copyWith(error: () => e.toString(), transactions: const []);
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      await _fetchTransactions();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> hasStoredWallet() async {
    try {
      return await _walletService.hasStoredWallet();
    } catch (e) {
      state = state.copyWith(error: () => e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: () => null);
  }

  Future<void> refreshWallet() async {
    if (state.wallet == null) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final refreshedWallet = await _walletService.refreshBalance(state.wallet!);

      if (mounted) {
        state = state.copyWith(wallet: () => refreshedWallet);
        state = state.copyWith(error: () => null);
      } else {
        debugPrint('⚠️ WalletNotifier.refreshWallet: Widget unmounted, skipping wallet update');
      }
    } catch (e) {

      if (mounted) {
        state = state.copyWith(error: () => e.toString());
      } else {
        debugPrint('⚠️ WalletNotifier.refreshWallet: Widget unmounted, skipping error state update');
      }
    } finally {
      if (mounted) {
        state = state.copyWith(isLoading: false);
      } else {
        debugPrint('⚠️ WalletNotifier.refreshWallet: Widget unmounted, skipping loading state update');
      }
    }
  }

  Future<void> disconnectWallet() async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      if (state.wallet != null) {
        await _walletService.disconnect(state.wallet!);
      }

      state = state.copyWith(wallet: () => null, error: () => null);
    } catch (e) {
      state = state.copyWith(error: () => e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> switchWallet() async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      if (state.wallet != null) {
        await _walletService.disconnect(state.wallet!);
      }

      state = state.copyWith(wallet: () => null, error: () => null);
    } catch (e) {
      state = state.copyWith(error: () => e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshTransactions() async {
    try {
      List<Wallet> userWallets = [];
      if (state.wallet != null) {
        userWallets = [state.wallet!];
      }

      final transactions = await _ethTransactionDataSource.getAllTransactions(
        userWallets: userWallets,
        knownReceivedHashes: null,
        limit: 10,
      );
      state = state.copyWith(transactions: List.unmodifiable(transactions));
    } catch (e) {
      debugPrint('⚠️ WalletNotifier.refreshTransactions: Failed to refresh transactions: $e');
    }
  }

  Future<void> fetchAllTransactions({int limit = 20, int offset = 0}) async {
    try {
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

      final updatedTransactions = offset == 0 
          ? List<Map<String, dynamic>>.unmodifiable(transactions)
          : List<Map<String, dynamic>>.unmodifiable([...state.allTransactions, ...transactions]);

      final hasMore = transactions.length >= limit;

      state = state.copyWith(
        allTransactions: updatedTransactions,
        hasMoreTransactions: hasMore,
        currentOffset: offset + transactions.length,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: () => e.toString(),
      );
    }
  }

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

  void resetAllTransactions() {
    state = state.copyWith(
      allTransactions: [],
      hasMoreTransactions: true,
      currentOffset: 0,
      isLoadingMore: false,
    );
  }
}