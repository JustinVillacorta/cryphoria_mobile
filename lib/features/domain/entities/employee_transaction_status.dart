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
      // Debug print to inspect the map
      print('Parsing transaction map: $map');

      // Extract and validate id
      final id = map['id'] as String? ?? 'unknown_id';

      // Extract and parse date (e.g., "May 31, 2023")
      final dateStr = map['date'] as String?;
      final date = dateStr != null ? DateFormat('MMMM d, yyyy').parse(dateStr) : DateTime.now();

      // Extract amount (e.g., "0.45 ETH") and parse it
      final amountStr = map['amount'] as String? ?? '0.0 ETH';
      final amountParts = amountStr.split(' ');
      final amountValue = double.tryParse(amountParts[0]) ?? 0.0;
      final currency = amountParts.length > 1 ? amountParts[1] : 'ETH';

      // Extract usdAmount (e.g., "$850.00 USD") and parse it
      final usdAmountStr = map['usdAmount'] as String? ?? '0.00 USD';
      final usdAmountCleaned = usdAmountStr
          .replaceAll('\$', '')  // Remove '$'
          .replaceAll(' USD', '')  // Remove ' USD'
          .trim();
      double usdAmountValue = double.tryParse(usdAmountCleaned) ?? 0.0;

      // If usdAmount is 0 or not provided, calculate using a fixed ETH-to-USD rate
      // (Example rate: 1 ETH ≈ $1890; update this based on current market or API)
      const double ethToUsdRate = 1890.0;
      if (usdAmountValue == 0.0 && currency == 'ETH') {
        usdAmountValue = amountValue * ethToUsdRate;
      }

      // Extract and validate status (e.g., "paid" or "Paid")
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
      // Debug print for error details
      print('Error parsing transaction: $e');
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