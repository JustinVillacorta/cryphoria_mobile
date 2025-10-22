import '../services/eth_payment_service.dart';

class TransactionsDataSource {
  TransactionsDataSource({required EthPaymentService ethPaymentService})
      : _ethPaymentService = ethPaymentService;

  final EthPaymentService _ethPaymentService;

  /// Returns recent payment transactions from the backend wallet/payment service.
  Future<List<Map<String, dynamic>>> getRecentTransactions({int limit = 10}) async {
    try {
      final ethTransactions =
          await _ethPaymentService.getRecentPaymentTransactions(limit: limit);
      return ethTransactions;
    } catch (e) {
      print('⚠️ Could not fetch recent transactions: $e');
      return <Map<String, dynamic>>[];
    }
  }
}
