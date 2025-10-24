import 'package:flutter/material.dart';
import '../data_sources/eth_payment_remote_data_source.dart';
import '../../domain/entities/eth_transaction.dart';
import '../../domain/entities/wallet.dart';
import 'wallet_service.dart';

class EthPaymentService {
  final EthPaymentRemoteDataSource remoteDataSource;
  final WalletService walletService;

  EthPaymentService({
    required this.remoteDataSource,
    required this.walletService,
  });

  /// Send ETH transaction with validation
  Future<EthTransactionResult> sendEthTransaction({
    required Wallet fromWallet,
    required String toAddress,
    required double amount,
    String? company,
    String? category,
    String? description,
    double? gasPrice,
    int? gasLimit,
  }) async {
    // Validate inputs
    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    if (!_isValidEthereumAddress(toAddress)) {
      throw Exception('Invalid recipient address format');
    }

    if (fromWallet.balance < amount) {
      throw Exception('Insufficient balance for transaction');
    }

    if (!fromWallet.isConnected) {
      throw Exception('Wallet is not connected');
    }

    try {
      // Use wallet service to send ETH (private key is handled by backend)
      final result = await walletService.sendEth(
        toAddress: toAddress,
        amount: amount,
        gasPrice: gasPrice?.toString(),
        gasLimit: gasLimit?.toString(),
        company: company,
        category: category,
        description: description,
        isInvesting: false, // Always false for payment transactions
        investorName: "", // Empty for payment transactions
      );

      // Debug logging
      print('🔍 EthPaymentService received result: $result');
      print('🔍 Result type: ${result.runtimeType}');
      print('🔍 Result keys: ${result.keys.toList()}');
      
      // Debug individual field types
      result.forEach((key, value) {
        print('🔍 $key: $value (${value.runtimeType})');
      });

      // Validate that we have a transaction hash
      final transactionHash = result['transaction_hash']?.toString() ?? '';
      if (transactionHash.isEmpty) {
        print('🚨 No transaction hash found in result: $result');
        throw Exception('Transaction failed: No transaction hash returned from server');
      }

      // Convert backend response to EthTransactionResult
      final ethResult = EthTransactionResult(
        transactionHash: transactionHash,
        fromAddress: result['from_address']?.toString() ?? fromWallet.address,
        toAddress: result['to_address']?.toString() ?? toAddress,
        amountEth: _parseDouble(result['amount_eth']) ?? amount,
        gasPrice: _parseDouble(result['gas_price_gwei']) ?? 0.0,
        gasLimit: _parseInt(result['gas_limit']) ?? 21000,
        gasUsed: _parseInt(result['gas_used']) ?? 21000,
        gasCostEth: _parseDouble(result['gas_cost_eth']) ?? 0.0,
        totalCostEth: _parseDouble(result['total_cost_eth']) ?? amount,
        status: result['status']?.toString() ?? 'pending',
        chainId: _parseInt(result['chain_id']) ?? 1,
        nonce: _parseInt(result['nonce']) ?? 0,
        fromWalletName: result['from_wallet_name']?.toString(),
        company: company,
        category: category,
        description: description,
        timestamp: DateTime.now(),
        accountingProcessed: _parseBool(result['accounting_processed']) ?? false,
      );

      print('✅ EthTransactionResult created successfully: ${ethResult.transactionHash}');
      return ethResult;
    } catch (e) {
      print('🚨 EthPaymentService.sendEthTransaction error: $e');
      rethrow;
    }
  }

  /// Estimate gas cost for transaction
  Future<GasEstimate> estimateGas({
    required String fromAddress,
    required String toAddress,
    required double amount,
  }) async {
    // Validate inputs
    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    if (!_isValidEthereumAddress(fromAddress)) {
      throw Exception('Invalid sender address format');
    }

    if (!_isValidEthereumAddress(toAddress)) {
      throw Exception('Invalid recipient address format');
    }

    final request = GasEstimateRequest(
      fromAddress: fromAddress,
      toAddress: toAddress,
      amount: amount,
    );

    try {
      return await remoteDataSource.estimateGas(request);
    } catch (e) {
      print('🚨 EthPaymentService.estimateGas error: $e');
      rethrow;
    }
  }

  /// Get transaction history for wallet
  Future<List<EthTransaction>> getTransactionHistory({
    String? walletId,
    int limit = 50,
    int offset = 0,
    String? status,
  }) async {
    try {
      return await remoteDataSource.getTransactionHistory(
        walletId: walletId,
        limit: limit,
        offset: offset,
        status: status,
      );
    } catch (e) {
      print('🚨 EthPaymentService.getTransactionHistory error: $e');
      rethrow;
    }
  }

  /// Get status of specific transaction
  Future<EthTransactionStatus> getTransactionStatus(String transactionHash) async {
    if (transactionHash.isEmpty) {
      throw Exception('Transaction hash cannot be empty');
    }

    try {
      return await remoteDataSource.getTransactionStatus(transactionHash);
    } catch (e) {
      print('🚨 EthPaymentService.getTransactionStatus error: $e');
      rethrow;
    }
  }

  /// Check if a transaction is received by a specific wallet
  Future<Map<String, dynamic>?> checkIfTransactionReceived({
    required String transactionHash,
    required List<String> userWalletAddresses,
  }) async {
    try {
      final txStatus = await getTransactionStatus(transactionHash);
      
      // Check if this transaction was sent TO any of the user's wallets
      final toAddressLower = txStatus.toAddress.toLowerCase();
      final isReceived = userWalletAddresses.any(
        (address) => address.toLowerCase() == toAddressLower,
      );
      
      if (isReceived) {
        return {
          'is_received': true,
          'transaction_data': txStatus,
          'receiving_address': txStatus.toAddress,
        };
      }
      
      return {'is_received': false};
    } catch (e) {
      print('🚨 EthPaymentService.checkIfTransactionReceived error: $e');
      return null; // Return null on error
    }
  }

  /// Get received transactions from a list of known transaction hashes
  Future<List<Map<String, dynamic>>> getReceivedTransactionsFromHashes({
    required List<String> transactionHashes,
    required List<String> userWalletAddresses,
  }) async {
    List<Map<String, dynamic>> receivedTransactions = [];
    
    for (String txHash in transactionHashes) {
      try {
        final result = await checkIfTransactionReceived(
          transactionHash: txHash,
          userWalletAddresses: userWalletAddresses,
        );
        
        if (result != null && result['is_received'] == true) {
          final txData = result['transaction_data'] as EthTransactionStatus;
          final displayTx = _convertReceivedToDisplayTransaction(txData);
          receivedTransactions.add(displayTx);
        }
      } catch (e) {
        print('🚨 Error checking transaction $txHash: $e');
        continue; // Skip this transaction and continue with others
      }
    }
    
    return receivedTransactions;
  }

  /// Convert received transaction to display format
  Map<String, dynamic> _convertReceivedToDisplayTransaction(EthTransactionStatus tx) {
    return {
      'title': 'ETH Received',
      'subtitle': _formatAddress(tx.fromAddress),
      'amount': '+${tx.amountEth} ETH',
      'time': _formatTransactionTime(DateTime.now()), // Would use actual timestamp from tx
      'icon': Icons.arrow_downward,
      'color': Colors.green,
      'isPositive': true,
      'type': 'eth_received',
      'status': tx.status,
      'transaction_hash': tx.transactionHash,
      'from_address': tx.fromAddress,
      'to_address': tx.toAddress,
      'gas_cost': '${tx.gasCostEth} ETH',
      'confirmations': tx.confirmations,
    };
  }

  /// Get recent payment transactions for display
  Future<List<Map<String, dynamic>>> getRecentPaymentTransactions({
    String? walletId,
    int limit = 10,
  }) async {
    try {
      final transactions = await getTransactionHistory(
        walletId: walletId,
        limit: limit,
        status: null, // Get all statuses
      );

      return transactions.map((tx) => _convertToDisplayTransaction(tx)).toList();
    } catch (e) {
      print('🚨 EthPaymentService.getRecentPaymentTransactions error: $e');
      return []; // Return empty list on error
    }
  }

  /// Convert ETH transaction to display format for home screen
  Map<String, dynamic> _convertToDisplayTransaction(EthTransaction tx) {
    // For now, assume all transactions from this service are outgoing payments
    // In future, this could be determined by comparing addresses with user's wallets
    
    return {
      'title': 'ETH Payment Sent',
      'subtitle': _formatAddress(tx.toAddress),
      'amount': '-${tx.amountEth.toStringAsFixed(6)} ETH',
      'time': _formatTransactionTime(tx.createdAt),
      'icon': Icons.arrow_upward,
      'color': Colors.red,
      'isPositive': false,
      'type': 'eth_payment',
      'status': tx.status,
      'transaction_hash': tx.transactionHash,
      'gas_cost': '${tx.gasCostEth.toStringAsFixed(6)} ETH',
      'description': tx.description,
      'category': tx.category,
    };
  }

  /// Validate Ethereum address format
  bool _isValidEthereumAddress(String address) {
    // Basic Ethereum address validation
    return address.startsWith('0x') && address.length == 42;
  }

  /// Safely parse a dynamic value to double
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Safely parse a dynamic value to int
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  /// Safely parse a dynamic value to bool
  bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    if (value is int) {
      return value != 0;
    }
    return null;
  }

  /// Format address for display
  String _formatAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  /// Format transaction time for display
  String _formatTransactionTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }


}