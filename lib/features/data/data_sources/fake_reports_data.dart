// lib/features/data/data_sources/fake_reports_data.dart
import '../../domain/entities/transaction_report.dart';

class FakeReportsData {
  static List<TransactionReport> getSampleTransactions() {
    return [
      TransactionReport(
        id: '1',
        type: 'sell',
        symbol: 'AMZN',
        amount: 750.00,
        date: DateTime(2023, 5, 28),
        status: 'completed',
      ),
      TransactionReport(
        id: '2',
        type: 'bought',
        symbol: 'AAPL',
        amount: 14750.00,
        date: DateTime(2023, 5, 15),
        status: 'completed',
      ),
      TransactionReport(
        id: '3',
        type: 'sell',
        symbol: 'TSLA',
        amount: 2350.00,
        date: DateTime(2023, 5, 10),
        status: 'completed',
      ),
      TransactionReport(
        id: '4',
        type: 'bought',
        symbol: 'GOOGL',
        amount: 8920.00,
        date: DateTime(2023, 4, 25),
        status: 'completed',
      ),
      TransactionReport(
        id: '5',
        type: 'sell',
        symbol: 'MSFT',
        amount: 1250.00,
        date: DateTime(2023, 4, 18),
        status: 'completed',
      ),
      TransactionReport(
        id: '6',
        type: 'bought',
        symbol: 'NVDA',
        amount: 5670.00,
        date: DateTime(2023, 4, 12),
        status: 'completed',
      ),
    ];
  }

  static List<TransactionReport> getFilteredTransactions({
    String? type,
    String? symbol,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var transactions = getSampleTransactions();

    if (type != null) {
      transactions = transactions.where((t) => t.type.toLowerCase() == type.toLowerCase()).toList();
    }

    if (symbol != null) {
      transactions = transactions.where((t) => t.symbol.toLowerCase().contains(symbol.toLowerCase())).toList();
    }

    if (startDate != null) {
      transactions = transactions.where((t) => t.date.isAfter(startDate) || t.date.isAtSameMomentAs(startDate)).toList();
    }

    if (endDate != null) {
      transactions = transactions.where((t) => t.date.isBefore(endDate) || t.date.isAtSameMomentAs(endDate)).toList();
    }

    return transactions;
  }

  static double getTotalAmount({String? type}) {
    final transactions = type != null 
        ? getFilteredTransactions(type: type)
        : getSampleTransactions();
    
    return transactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  static int getTransactionCount({String? type}) {
    final transactions = type != null 
        ? getFilteredTransactions(type: type)
        : getSampleTransactions();
    
    return transactions.length;
  }
}
