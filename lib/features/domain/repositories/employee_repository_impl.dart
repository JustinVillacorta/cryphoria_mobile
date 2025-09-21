import 'package:cryphoria_mobile/features/domain/entities/employee_top_bar.dart';
import 'package:cryphoria_mobile/features/domain/entities/employee_transaction_status.dart';
import 'package:cryphoria_mobile/features/domain/entities/employee_wallet.dart';
import '../../domain/entities/employee_payout_info.dart';
import '../../domain/repositories/employee_repository.dart';
import '../../data/data_sources/EmployeeRemoteDataSource.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;

  EmployeeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<EmployeeTopBar> getEmployeeData(String employeeId) async {
    final data = await remoteDataSource.getEmployeeData(employeeId);
    return EmployeeTopBar(
      id: data['id'],
      name: data['name'],
      avatarUrl: data['avatar_url'] ?? '',
    );
  }

  @override
  Future<WalletEmployee> getWalletData(String employeeId) async {
    final data = await remoteDataSource.getWalletData(employeeId);
    return WalletEmployee(
      currency: data['currency'],
      balance: data['balance'].toDouble(),
      convertedAmount: data['converted_amount'].toDouble(),
      convertedCurrency: data['converted_currency'],
    );
  }

  @override
  Future<PayoutInfo> getPayoutInfo(String employeeId) async {
    final data = await remoteDataSource.getPayoutInfo(employeeId);
    return PayoutInfo(
      nextPayoutDate: DateTime.parse(data['next_payout_date']),
      frequency: data['frequency'],
    );
  }

  @override
  Future<List<Transaction>> getRecentTransactions(String employeeId, {int limit = 5}) async {
    final data = await remoteDataSource.getRecentTransactions(employeeId, limit: limit);
    print('Raw data from remote: $data');
    return data.asMap().entries.map((entry) {
      final index = entry.key + 1; // 0-based index to 1, 2, 3...
      final item = entry.value;
      return Transaction(
        id: '0x${index.toRadixString(16).padLeft(40, '0')}', // Convert to hex and pad to 40 chars
        date: DateTime.parse(item['date']),
        amount: item['amount'].toDouble(),
        currency: item['currency'],
        usdAmount: item['usd_amount'].toDouble(),
        status: _parseTransactionStatus(item['status']),
      );
    }).toList();
  }

  TransactionStatus _parseTransactionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return TransactionStatus.paid;
      case 'pending':
        return TransactionStatus.pending;
      case 'failed':
        return TransactionStatus.failed;
      default:
        return TransactionStatus.pending;
    }
  }
}