import '../../entities/payroll_period.dart';
import '../../repositories/payroll_repository.dart';

class GetPayrollPeriodsUseCase {
  final PayrollRepository repository;

  GetPayrollPeriodsUseCase({required this.repository});

  Future<List<PayrollPeriod>> execute() async {
    return await repository.getPayrollPeriods();
  }
}
