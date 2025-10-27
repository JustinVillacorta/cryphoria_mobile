import '../services/eth_payment_service.dart';

class TransactionsDataSource {
  TransactionsDataSource({required EthPaymentService ethPaymentService})
      : _ethPaymentService = ethPaymentService;

  final EthPaymentService _ethPaymentService;

  Future<List<Map<String, dynamic>>> getRecentTransactions({int limit = 10}) async {
    try {
      final ethTransactions =
          await _ethPaymentService.getRecentPaymentTransactions(limit: limit);
      return ethTransactions;
    } catch (e) {
      return <Map<String, dynamic>>[];
    }
  }
}