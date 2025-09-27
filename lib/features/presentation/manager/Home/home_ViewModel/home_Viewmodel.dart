import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/features/data/services/wallet_service.dart';
import 'package:cryphoria_mobile/features/domain/entities/wallet.dart';
import 'package:cryphoria_mobile/features/data/data_sources/eth_transaction_data_source.dart';

class WalletState {
  final Wallet? wallet;
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> transactions;

  const WalletState({
    required this.wallet,
    required this.isLoading,
    required this.error,
    required this.transactions,
  });

  factory WalletState.initial() => const WalletState(
        wallet: null,
        isLoading: false,
        error: null,
        transactions: [],
      );

  WalletState copyWith({
    Wallet? wallet,
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? transactions,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      transactions: transactions ?? this.transactions,
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

  /// Loads initial data (e.g., transactions) and checks for stored wallet on initialization
  Future<void> _loadInitialData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // First check for stored wallet and reconnect
      if (await _walletService.hasStoredWallet()) {
        await reconnect();
      }
      
      // Then load transactions (now that wallet is connected if it was stored)
      await _fetchTransactions();
      state = state.copyWith(error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Connects to a wallet with the provided private key
  Future<void> connect(
      String privateKey, {
        String? endpoint,
        String? walletName,
        String? walletType,
      }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final wallet = await _walletService.connectWallet(
        privateKey,
        endpoint: endpoint ?? 'http://localhost:8545',
        walletName: walletName ?? 'My Wallet',
        walletType: walletType ?? 'imported',
      );
      
      // Wallet connected successfully - fetch transactions now
      state = state.copyWith(wallet: wallet);
      await _fetchTransactions();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Reconnects to a previously stored wallet
  Future<void> reconnect() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final wallet = await _walletService.reconnect();
      state = state.copyWith(wallet: wallet);
      
      // Wallet reconnected successfully - fetch transactions now
      await _fetchTransactions();
    } catch (e) {
      state = state.copyWith(error: e.toString());
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
      
      state = state.copyWith(transactions: List.unmodifiable(transactions), error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString(), transactions: const []);
      print('⚠️ Failed to fetch transactions: $e');
    }
  }

  /// Refreshes transaction data (e.g., on pull-to-refresh)
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
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
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Clears the current error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refreshes the current wallet balance and PHP conversion
  Future<void> refreshWallet() async {
    if (state.wallet == null) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      // Reconnect to refresh balance and conversion
      final refreshedWallet = await _walletService.reconnect();
      if (refreshedWallet != null) {
        state = state.copyWith(wallet: refreshedWallet);
      }
      state = state.copyWith(error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Disconnects the current wallet
  Future<void> disconnectWallet() async {
    try {
      await _walletService.disconnect();
      state = state.copyWith(wallet: null, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
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
}
