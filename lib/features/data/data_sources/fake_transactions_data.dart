import 'package:flutter/material.dart';

import '../services/eth_payment_service.dart';

class FakeTransactionsDataSource {
  FakeTransactionsDataSource({EthPaymentService? ethPaymentService})
      : _ethPaymentService = ethPaymentService;

  final EthPaymentService? _ethPaymentService;
  final List<Map<String, dynamic>> _transactions = [
    // Recent transactions
    {
      'title': 'Bought',
      'subtitle': 'AAPL',
      'amount': '\$9,300.00',
      'time': 'Jan 19, 2023',
      'icon': Icons.trending_up,
      'color': Colors.green,
      'isPositive': false,
      'type': 'buy',
      'price': '\$150.00',
      'fee': '\$0.00',
    },
    {
      'title': 'Bought',
      'subtitle': 'MSFT',
      'amount': '\$4,150.00',
      'time': 'Jan 5, 2023',
      'icon': Icons.trending_up,
      'color': Colors.green,
      'isPositive': false,
      'type': 'buy',
      'price': '\$415.99',
      'fee': '\$0.00',
    },
    {
      'title': 'Sell',
      'subtitle': 'AMZN',
      'amount': '\$750.00',
      'time': 'May 28, 2023',
      'icon': Icons.trending_down,
      'color': Colors.red,
      'isPositive': true,
      'type': 'sell',
      'price': '\$150.00',
      'fee': '\$0.00',
    },
    {
      'title': 'Bought',
      'subtitle': 'AAPL',
      'amount': '\$14,750.00',
      'time': 'May 15, 2023',
      'icon': Icons.trending_up,
      'color': Colors.green,
      'isPositive': false,
      'type': 'buy',
      'price': '\$300.00',
      'fee': '\$5.00',
    },
    {
      'title': 'Bought',
      'subtitle': 'JPM',
      'amount': '\$3,200.00',
      'time': 'May 16, 2023',
      'icon': Icons.trending_up,
      'color': Colors.green,
      'isPositive': false,
      'type': 'buy',
      'price': '\$160.00',
      'fee': '\$0.00',
    },
    {
      'title': 'Bought',
      'subtitle': 'MSFT',
      'amount': '\$3,500.00',
      'time': 'May 1, 2023',
      'icon': Icons.trending_up,
      'color': Colors.green,
      'isPositive': false,
      'type': 'buy',
      'price': '\$700.00',
      'fee': '\$0.00',
    },
    {
      'title': 'Bought',
      'subtitle': 'AMZN',
      'amount': '\$12,400.00',
      'time': 'Apr 24, 2023',
      'icon': Icons.trending_up,
      'color': Colors.green,
      'isPositive': false,
      'type': 'buy',
      'price': '\$3,100.00',
      'fee': '\$5.00',
    },
    // Legacy transactions for home screen compatibility
    {
      'title': 'Client Payment',
      'subtitle': 'Johnson & Co.',
      'amount': '+\$1250.00',
      'time': 'Today, 10:24 AM',
      'icon': Icons.arrow_downward,
      'color': Colors.green,
      'isPositive': true,
      'type': 'payment',
    },
    {
      'title': 'Investment Purchase',
      'subtitle': 'BTC Portfolio',
      'amount': '\$342.68',
      'time': 'Today, 9:15 AM',
      'icon': Icons.trending_up,
      'color': Colors.orange,
      'isPositive': false,
      'type': 'investment',
    },
    {
      'title': 'Payroll Processed',
      'subtitle': 'Staff Salaries',
      'amount': '\$128.50',
      'time': 'Yesterday',
      'icon': Icons.people,
      'color': Colors.blue,
      'isPositive': false,
      'type': 'payroll',
    },
    {
      'title': 'Client Payment',
      'subtitle': 'Wilson & Co.',
      'amount': '+\$1250.00',
      'time': 'Today, 10:24 AM',
      'icon': Icons.arrow_downward,
      'color': Colors.green,
      'isPositive': true,
      'type': 'payment',
    },
    {
      'title': 'Investment Purchase',
      'subtitle': 'ETH Portfolio',
      'amount': '\$899.99',
      'time': '3 days ago',
      'icon': Icons.trending_up,
      'color': Colors.purple,
      'isPositive': false,
      'type': 'investment',
    },
  ];

  List<Map<String, dynamic>> getTransactions() => List.unmodifiable(_transactions);
  
  /// Get mixed transactions including real ETH payments (sent & received) and mock data
  Future<List<Map<String, dynamic>>> getMixedTransactions({int limit = 10}) async {
    List<Map<String, dynamic>> allTransactions = [];
    
    // Try to get recent ETH payment transactions (sent)
    if (_ethPaymentService != null) {
      try {
        final ethTransactions =
            await _ethPaymentService.getRecentPaymentTransactions(limit: 2);
        allTransactions.addAll(ethTransactions);
      } catch (e) {
        print('⚠️ Could not fetch ETH sent transactions: $e');
      }
    }
    
    // Add mock transactions to fill remaining slots
    final remainingSlots = limit - allTransactions.length;
    if (remainingSlots > 0) {
      allTransactions.addAll(_transactions.take(remainingSlots));
    }
    
    // Sort by time (newest first) - for now keep existing order
    // In a real implementation, you'd parse timestamps and sort properly
    
    return allTransactions.take(limit).toList();
  }

}
