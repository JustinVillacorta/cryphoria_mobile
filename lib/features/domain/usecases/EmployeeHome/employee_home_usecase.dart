
import '../../entities/employee_top_bar.dart';
import '../../entities/employee_transaction_status.dart';
import '../../entities/employee_payout_info.dart';
import '../../entities/employee_wallet.dart';
import '../../../data/data_sources/EmployeeRemoteDataSource.dart';

class EmployeeDashboardData {
  final EmployeeTopBar employee;
  final WalletEmployee wallet;
  final PayoutInfo payoutInfo;
  final List<Transaction> recentTransactions;

  EmployeeDashboardData({
    required this.employee,
    required this.wallet,
    required this.payoutInfo,
    required this.recentTransactions,
  });
}

class GetEmployeeDashboardData {
  final EmployeeRemoteDataSource dataSource;

  GetEmployeeDashboardData({required this.dataSource});

  Future<EmployeeDashboardData> call(String employeeId) async {
    try {
      final results = await Future.wait([
        dataSource.getEmployeeData(employeeId),
        dataSource.getWalletData(employeeId),
        dataSource.getPayoutInfo(employeeId),
        dataSource.getRecentTransactions(employeeId, limit: 5),
      ]);

      return EmployeeDashboardData(
        employee: EmployeeTopBar(
          id: (results[0] as Map<String, dynamic>)['id'] as String,
          name: (results[0] as Map<String, dynamic>)['name'] as String,
          avatarUrl: (results[0] as Map<String, dynamic>)['avatar_url'] as String? ?? '',
        ),
        wallet: WalletEmployee(
          currency: (results[1] as Map<String, dynamic>)['currency'] as String,
          balance: (results[1] as Map<String, dynamic>)['balance'] as double,
          convertedAmount: (results[1] as Map<String, dynamic>)['converted_amount'] as double,
          convertedCurrency: (results[1] as Map<String, dynamic>)['converted_currency'] as String,
        ),
        payoutInfo: PayoutInfo(
          nextPayoutDate: DateTime.parse((results[2] as Map<String, dynamic>)['next_payout_date'] as String),
          frequency: (results[2] as Map<String, dynamic>)['frequency'] as String,
        ),
        recentTransactions: (results[3] as List<Map<String, dynamic>>)
            .map((transactionMap) => Transaction.fromMap(transactionMap))
            .toList(),
      );
    } catch (e) {
      throw Exception('Failed to load dashboard data: $e');
    }
  }
}