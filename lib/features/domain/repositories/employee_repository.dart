// lib/features/domain/repositories/employee_repository.dart
import 'package:cryphoria_mobile/features/domain/entities/employee_top_bar.dart';
import 'package:cryphoria_mobile/features/domain/entities/employee_wallet.dart';

import '../entities/employee.dart';
import '../entities/wallet.dart';
import '../entities/employee_payout_info.dart';
import '../entities/employee_transaction_status.dart';

abstract class EmployeeRepository {
  Future<EmployeeTopBar> getEmployeeData(String employeeId);
  Future<WalletEmployee> getWalletData(String employeeId);
  Future<PayoutInfo> getPayoutInfo(String employeeId);
  Future<List<Transaction>> getRecentTransactions(String employeeId, {int limit = 5});
}