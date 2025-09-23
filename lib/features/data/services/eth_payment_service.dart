import 'package:flutter/material.dart';
import '../data_sources/eth_payment_remote_data_source.dart';
import '../../domain/entities/eth_transaction.dart';
import '../../domain/entities/wallet.dart';

class EthPaymentService {
  final EthPaymentRemoteDataSource remoteDataSource;

  EthPaymentService({required this.remoteDataSource});

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

    // Create transaction request
    final request = EthTransactionRequest(
      fromWalletId: fromWallet.id,
      fromAddress: fromWallet.address,
      toAddress: toAddress,
      amount: amount,
      privateKey: fromWallet.private_key,
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      company: company,
      category: category,
      description: description,
    );

    try {
      return await remoteDataSource.sendEthTransaction(request);
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