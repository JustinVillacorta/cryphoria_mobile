// lib/features/domain/entities/transaction_report.dart
class TransactionReport {
  final String id;
  final String type; // 'buy' or 'sell'
  final String symbol;
  final double amount;
  final DateTime date;
  final String status;

  TransactionReport({
    required this.id,
    required this.type,
    required this.symbol,
    required this.amount,
    required this.date,
    this.status = 'completed',
  });

  bool get isSell => type.toLowerCase() == 'sell';
  bool get isBuy => type.toLowerCase() == 'buy' || type.toLowerCase() == 'bought';
  
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  
  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
