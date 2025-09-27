import 'package:flutter/material.dart';

import '../../../core/network/dio_client.dart';
import '../../domain/entities/wallet.dart';

/// Dedicated data source for ETH transactions - handles both sent and received
/// Now uses the new backend category endpoints for better transaction filtering
class EthTransactionDataSource {
  EthTransactionDataSource({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  /// Fetch ETH transactions by category (SENT, RECEIVED, TRANSFER)
  Future<List<Map<String, dynamic>>> getTransactionsByCategory(String category) async {
    try {
      final response = await _dioClient.dio.get('/api/eth/history/category/', queryParameters: {
        'category': category,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map && data.containsKey('transactions')) {
          final transactions = data['transactions'] as List;
          final convertedTransactions = transactions
              .map((tx) => _convertBackendTransactionToDisplay(tx, category))
              .toList();
          
          return convertedTransactions;
        } else if (data is List) {
          final convertedTransactions = data
              .map((tx) => _convertBackendTransactionToDisplay(tx, category))
              .toList();
          
          return convertedTransactions;
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to fetch ${category.toLowerCase()} transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching ${category.toLowerCase()} transactions: $e');
    }
  }

  /// Get received ETH transactions using the new backend category endpoint
  Future<List<Map<String, dynamic>>> getReceivedTransactions({
    int limit = 10,
  }) async {
    return await getTransactionsByCategory('RECEIVED');
  }

  /// Get sent ETH transactions using the new backend category endpoint
  Future<List<Map<String, dynamic>>> getSentTransactions({
    int limit = 10,
  }) async {
    return await getTransactionsByCategory('SENT');
  }

  /// Get transfer transactions (wallet-to-wallet transfers)
  Future<List<Map<String, dynamic>>> getTransferTransactions({
    int limit = 10,
  }) async {
    return await getTransactionsByCategory('TRANSFER');
  }

  /// Convert backend transaction data to display format
  Map<String, dynamic> _convertBackendTransactionToDisplay(
    Map<String, dynamic> backendTx, 
    String category
  ) {
    final isReceived = category == 'RECEIVED';
    final isTransfer = category == 'TRANSFER';
    
    String title;
    IconData icon;
    Color color;
    String amountPrefix;
    
    if (isReceived) {
      title = 'ETH Received';
      icon = Icons.arrow_downward;
      color = Colors.green;
      amountPrefix = '+';
    } else if (isTransfer) {
      title = 'ETH Transfer';
      icon = Icons.swap_horiz;
      color = Colors.blue;
      amountPrefix = '↔';
    } else {
      title = 'ETH Sent';
      icon = Icons.arrow_upward;
      color = Colors.red;
      amountPrefix = '-';
    }

    // Handle various possible field names from backend
    final amount = backendTx['amount_eth'] ?? 
                   backendTx['amount'] ?? 
                   backendTx['value'] ?? 
                   '0';
    
    final timestamp = backendTx['created_at'] ?? 
                     backendTx['timestamp'] ?? 
                     backendTx['time'] ?? 
                     DateTime.now().toIso8601String();
                     
    final fromAddress = backendTx['from_address'] ?? 
                       backendTx['fromAddress'] ?? 
                       backendTx['sender'] ?? '';
                       
    final toAddress = backendTx['to_address'] ?? 
                     backendTx['toAddress'] ?? 
                     backendTx['recipient'] ?? '';

    return {
      'title': title,
      'subtitle': _formatAddress(fromAddress),
      'amount': '$amountPrefix$amount ETH',
      'time': _formatTransactionTime(
        DateTime.tryParse(timestamp) ?? DateTime.now()
      ),
      'icon': icon,
      'color': color,
      'isPositive': isReceived,
      'type': 'eth_${category.toLowerCase()}',
      'status': backendTx['status'] ?? 'unknown',
      'transaction_hash': backendTx['transaction_hash'] ?? backendTx['hash'] ?? '',
      'from_address': fromAddress,
      'to_address': toAddress,
      'from_wallet_name': backendTx['from_wallet_name'] ?? 'Unknown',
      'gas_cost': '${backendTx['gas_cost_eth'] ?? backendTx['gas_cost'] ?? '0'} ETH',
      'confirmations': backendTx['confirmations'] ?? 0,
      'network': backendTx['network'] ?? 'ethereum',
      'company': backendTx['company'] ?? '',
      'category_description': backendTx['category_description'] ?? category,
      'description': backendTx['description'] ?? '',
      'transaction_category': backendTx['transaction_category'] ?? category,
      'created_at': timestamp, // Keep original timestamp for sorting
      'timestamp': timestamp,  // Backup field for sorting
    };
  }

  /// Get mixed transactions including both sent and received ETH transactions
  Future<List<Map<String, dynamic>>> getMixedTransactions({
    int limit = 10,
    List<Wallet>? userWallets,
  }) async {
    try {
      print('🚀 Fetching all ETH transactions with category=ALL...');
      
      // Get ALL transactions from backend in one call
      final response = await _dioClient.dio.get('/api/eth/history/category/', queryParameters: {
        'category': 'ALL',
        'limit': limit,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        List<Map<String, dynamic>> allTransactions = [];
        
        if (data is Map && data.containsKey('data') && data['data'].containsKey('transactions')) {
          final transactions = data['data']['transactions'] as List;
          print('📦 Retrieved ${transactions.length} total transactions from backend');
          
          // Convert all transactions to display format
          for (var tx in transactions) {
            final category = tx['transaction_category'] ?? 'SENT';
            final convertedTx = _convertBackendTransactionToDisplay(tx, category);
            allTransactions.add(convertedTx);
          }
          
          // Sort by timestamp
          allTransactions.sort((a, b) {
            final aTime = a['created_at'] ?? a['timestamp'] ?? '';
            final bTime = b['created_at'] ?? b['timestamp'] ?? '';
            return bTime.compareTo(aTime); // Most recent first
          });
          
          print('✅ Converted ${allTransactions.length} ETH transactions');
          
          return allTransactions.take(limit).toList();
        } else {
          print('⚠️ Unexpected response format: ${data.runtimeType}');
          return [];
        }
      } else {
        throw Exception('Failed to fetch transactions: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Error fetching ETH transactions: $e');
      return [];
    }
  }

  /// Format address for display (shows first 6 and last 4 characters)
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

  /// Test method to debug the category endpoint
  Future<void> testCategoryEndpoint() async {
    print('🧪 Testing category endpoints...');
    
    try {
      final receivedTx = await getReceivedTransactions(limit: 5);
      print('🟢 RECEIVED test result: ${receivedTx.length} transactions');
      
      final sentTx = await getSentTransactions(limit: 5);
      print('🔴 SENT test result: ${sentTx.length} transactions');
      
      final transferTx = await getTransferTransactions(limit: 5);
      print('🔵 TRANSFER test result: ${transferTx.length} transactions');
      
    } catch (e) {
      print('❌ Test failed: $e');
    }
  }

  /// Get all transactions (sent + received + transfers) combined using new category endpoints
  Future<List<Map<String, dynamic>>> getAllTransactions({
    required List<Wallet> userWallets,
    List<String>? knownReceivedHashes, // No longer needed but kept for compatibility
    int limit = 10,
  }) async {
    // Use the new getMixedTransactions method which leverages category endpoints
    return await getMixedTransactions(limit: limit, userWallets: userWallets);
  }
}
