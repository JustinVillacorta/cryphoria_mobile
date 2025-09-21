
import '../../entities/employee_top_bar.dart';
import '../../entities/employee_transaction_status.dart';
import '../../entities/employee_payout_info.dart';
import '../../entities/employee_top_bar.dart';
import '../../entities/employee_wallet.dart';
import '../../repositories/employee_repository.dart';

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
  final EmployeeRepository repository;

  GetEmployeeDashboardData({required this.repository});

  Future<EmployeeDashboardData> call(String employeeId) async {
    try {
      final results = await Future.wait([
        repository.getEmployeeData(employeeId),
        repository.getWalletData(employeeId),
        repository.getPayoutInfo(employeeId),
        repository.getRecentTransactions(employeeId, limit: 5),
      ]);

      return EmployeeDashboardData(
        employee: results[0] as EmployeeTopBar,
        wallet: results[1] as WalletEmployee,
        payoutInfo: results[2] as PayoutInfo,
        recentTransactions: results[3] as List<Transaction>,
      );
    } catch (e) {
      throw Exception('Failed to load dashboard data: $e');
    }
  }
}