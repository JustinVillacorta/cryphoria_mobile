import 'package:flutter/material.dart';


import '../../../core/network/dio_client.dart';
import '../../domain/entities/wallet.dart';

class EthTransactionDataSource {
  EthTransactionDataSource({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

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
              .map((tx) => _convertBackendTransactionToDisplay(tx, category, null))
              .toList();

          return convertedTransactions;
        } else if (data is List) {
          final convertedTransactions = data
              .map((tx) => _convertBackendTransactionToDisplay(tx, category, null))
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

  Future<List<Map<String, dynamic>>> getReceivedTransactions({
    int limit = 10,
  }) async {
    return await getTransactionsByCategory('RECEIVED');
  }

  Future<List<Map<String, dynamic>>> getSentTransactions({
    int limit = 10,
  }) async {
    return await getTransactionsByCategory('SENT');
  }

  Future<List<Map<String, dynamic>>> getTransferTransactions({
    int limit = 10,
  }) async {
    return await getTransactionsByCategory('TRANSFER');
  }

  Map<String, dynamic> _convertBackendTransactionToDisplay(
    Map<String, dynamic> backendTx, 
    String category,
    String? userWalletAddress
  ) {
    final fromAddr = (backendTx['from_address'] ?? '').toString().toLowerCase();
    final toAddr = (backendTx['to_address'] ?? '').toString().toLowerCase();

    final isReceived = userWalletAddress != null && 
                      userWalletAddress.isNotEmpty && 
                      toAddr == userWalletAddress;

    final isSent = userWalletAddress != null && 
                  userWalletAddress.isNotEmpty && 
                  fromAddr == userWalletAddress;

    String title;
    IconData icon;
    Color color;
    String amountPrefix;
    String subtitle;

    if (isReceived) {
      title = 'Received';
      icon = Icons.arrow_downward;
      color = Colors.green;
      amountPrefix = '+';
      subtitle = _formatAddress(backendTx['from_address'] ?? '');
    } else if (isSent) {
      title = 'Sent';
      icon = Icons.arrow_upward;
      color = Colors.red;
      amountPrefix = '-';
      subtitle = _formatAddress(backendTx['to_address'] ?? '');
    } else {
      title = 'Transaction';
      icon = Icons.swap_horiz;
      color = Colors.blue;
      amountPrefix = '';
      subtitle = backendTx['company'] ?? backendTx['category'] ?? 'External';
    }

    final amount = backendTx['amount_eth'] ?? 
                   backendTx['amount'] ?? 
                   backendTx['value'] ?? 
                   '0';

    final timestamp = backendTx['created_at'] ?? 
                     backendTx['timestamp'] ?? 
                     backendTx['time'] ?? 
                     DateTime.now().toIso8601String();

    return {
      'title': title,
      'subtitle': subtitle,
      'amount': '$amountPrefix$amount ETH',
      'time': _formatTransactionTime(
        DateTime.tryParse(timestamp) ?? DateTime.now()
      ),
      'icon': icon,
      'color': color,
      'isPositive': isReceived,
      'type': 'eth_${isReceived ? 'received' : isSent ? 'sent' : 'transaction'}',
      'status': backendTx['status'] ?? 'unknown',
      'transaction_hash': backendTx['transaction_hash'] ?? backendTx['hash'] ?? '',
      'from_address': fromAddr,
      'to_address': toAddr,
      'from_wallet_name': backendTx['from_wallet_name'] ?? 'Unknown',
      'gas_cost': '${backendTx['gas_cost_eth'] ?? backendTx['gas_cost'] ?? '0'} ETH',
      'confirmations': backendTx['confirmations'] ?? 0,
      'network': backendTx['network'] ?? 'ethereum',
      'company': backendTx['company'] ?? '',
      'category_description': backendTx['category_description'] ?? category,
      'description': backendTx['description'] ?? '',
      'transaction_category': category,
      'created_at': timestamp,
      'timestamp': timestamp,
      'sender_name': backendTx['sender_name'],
      'receiver_name': backendTx['receiver_name'],
    };
  }

  Future<List<Map<String, dynamic>>> getMixedTransactions({
    int limit = 10,
    int offset = 0,
    List<Wallet>? userWallets,
  }) async {
    try {
      debugPrint('🚀 Fetching all ETH transactions from /api/eth/history/...');

      final response = await _dioClient.dio.get('/api/eth/history/', queryParameters: {
        'limit': limit,
        'offset': offset,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        List<Map<String, dynamic>> allTransactions = [];

        debugPrint('🔍 API Response: ${data.runtimeType}');
        debugPrint('🔍 Response keys: ${data is Map ? data.keys.toList() : 'Not a map'}');

        if (data is Map && data['success'] == true && data.containsKey('data') && data['data'].containsKey('transactions')) {
          final transactions = data['data']['transactions'] as List;
          debugPrint('📦 Retrieved ${transactions.length} total transactions from backend');

          final userWalletAddress = userWallets?.isNotEmpty == true ? userWallets!.first.address.toLowerCase() : null;
          debugPrint('🔍 User wallet address: $userWalletAddress');

          for (var tx in transactions) {
            final category = tx['transaction_category'] ?? 'SENT';
            final convertedTx = _convertBackendTransactionToDisplay(tx, category, userWalletAddress);
            allTransactions.add(convertedTx);
            debugPrint('🔍 Converted transaction: ${convertedTx['title']} - ${convertedTx['subtitle']} - ${convertedTx['amount']}');
          }

          allTransactions.sort((a, b) {
            final aTime = a['created_at'] ?? a['timestamp'] ?? '';
            final bTime = b['created_at'] ?? b['timestamp'] ?? '';
            return bTime.compareTo(aTime);
          });

          debugPrint('✅ Converted ${allTransactions.length} ETH transactions');
          debugPrint('🔍 First transaction: ${allTransactions.isNotEmpty ? allTransactions.first : 'None'}');

          return allTransactions.take(limit).toList();
        } else {
          debugPrint('⚠️ Unexpected response format: ${data.runtimeType}');
          debugPrint('⚠️ Response structure: $data');
          return [];
        }
      } else {
        throw Exception('Failed to fetch transactions: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching ETH transactions: $e');
      return [];
    }
  }

  String _formatAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

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

  Future<void> testCategoryEndpoint() async {
    debugPrint('🧪 Testing category endpoints...');

    try {
      await getReceivedTransactions(limit: 5);
      final receivedTx = await getReceivedTransactions(limit: 5);
      debugPrint('🟢 RECEIVED test result: ${receivedTx.length} transactions');

      await getSentTransactions(limit: 5);
      final sentTx = await getSentTransactions(limit: 5);
      debugPrint('🔴 SENT test result: ${sentTx.length} transactions');

      await getTransferTransactions(limit: 5);
      final transferTx = await getTransferTransactions(limit: 5);
      debugPrint('🔵 TRANSFER test result: ${transferTx.length} transactions');

    } catch (e) {
      debugPrint('❌ Test failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllTransactions({
    required List<Wallet> userWallets,
    List<String>? knownReceivedHashes,
    int limit = 10,
    int offset = 0,
  }) async {
    return await getMixedTransactions(limit: limit, offset: offset, userWallets: userWallets);
  }
}