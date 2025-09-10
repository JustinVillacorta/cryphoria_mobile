import 'package:flutter/material.dart';

class FakeTransactionsDataSource {
  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Client Payment',
      'subtitle': 'Johnson & Co.',
      'amount': '+\$1250.00',
      'time': 'Today, 10:24 AM',
      'icon': Icons.arrow_downward,
      'color': Colors.green,
      'isPositive': true,
    },
    {
      'title': 'Investment Purchase',
      'subtitle': 'BTC Portfolio',
      'amount': '\$342.68',
      'time': 'Today, 9:15 AM',
      'icon': Icons.trending_up,
      'color': Colors.orange,
      'isPositive': false,
    },
    {
      'title': 'Payroll Processed',
      'subtitle': 'Staff Salaries',
      'amount': '\$128.50',
      'time': 'Yesterday',
      'icon': Icons.people,
      'color': Colors.blue,
      'isPositive': false,
    },
    {
      'title': 'Client Payment',
      'subtitle': 'Wilson & Co.',
      'amount': '+\$1250.00',
      'time': 'Today, 10:24 AM',
      'icon': Icons.arrow_downward,
      'color': Colors.green,
      'isPositive': true,
    },
    {
      'title': 'Investment Purchase',
      'subtitle': 'ETH Portfolio',
      'amount': '\$899.99',
      'time': '3 days ago',
      'icon': Icons.trending_up,
      'color': Colors.purple,
      'isPositive': false,
    },
  ];

  List<Map<String, dynamic>> getTransactions() => List.unmodifiable(_transactions);
}