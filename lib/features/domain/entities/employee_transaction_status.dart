import 'package:intl/intl.dart';

enum TransactionStatus { paid, pending, failed }

class Transaction {
  final String id;
  final DateTime date;
  final double amount;
  final String currency;
  final double usdAmount;
  final TransactionStatus status;

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.currency,
    required this.usdAmount,
    required this.status,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    try {

      final id = map['id'] as String? ?? 'unknown_id';

      final dateStr = map['date'] as String?;
      final date = dateStr != null ? DateFormat('MMMM d, yyyy').parse(dateStr) : DateTime.now();

      final amountStr = map['amount'] as String? ?? '0.0 ETH';
      final amountParts = amountStr.split(' ');
      final amountValue = double.tryParse(amountParts[0]) ?? 0.0;
      final currency = amountParts.length > 1 ? amountParts[1] : 'ETH';

      final usdAmountStr = map['usdAmount'] as String? ?? '0.00 USD';
      final usdAmountCleaned = usdAmountStr
          .replaceAll('\$', '')
          .replaceAll(' USD', '')
          .trim();
      double usdAmountValue = double.tryParse(usdAmountCleaned) ?? 0.0;

      const double ethToUsdRate = 1890.0;
      if (usdAmountValue == 0.0 && currency == 'ETH') {
        usdAmountValue = amountValue * ethToUsdRate;
      }

      final statusStr = map['status'] as String?;
      final status = statusStr != null
          ? TransactionStatus.values.firstWhere(
            (e) => e.toString().toLowerCase() == 'TransactionStatus.${statusStr.toLowerCase()}',
        orElse: () => TransactionStatus.pending,
      )
          : TransactionStatus.pending;

      return Transaction(
        id: id,
        date: date,
        amount: amountValue,
        currency: currency,
        usdAmount: usdAmountValue,
        status: status,
      );
    } catch (e) {
      return Transaction(
        id: map['id'] as String? ?? 'unknown_id',
        date: DateTime.now(),
        amount: 0.0,
        currency: 'ETH',
        usdAmount: 0.0,
        status: TransactionStatus.pending,
      );
    }
  }
}