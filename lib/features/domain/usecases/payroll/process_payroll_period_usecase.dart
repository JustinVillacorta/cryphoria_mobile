import '../../entities/payroll_period.dart';
import '../../repositories/payroll_repository.dart';

class ProcessPayrollPeriodUseCase {
  final PayrollRepository repository;

  ProcessPayrollPeriodUseCase({required this.repository});

  Future<PayrollPeriod> execute(String periodId) async {
    if (periodId.isEmpty) {
      throw Exception('Period ID cannot be empty');
    }

    final period = await repository.getPayrollPeriod(periodId);

    if (!period.canProcess) {
      throw Exception('Payroll period cannot be processed in its current state');
    }

    return await repository.processPayrollPeriod(periodId);
  }
}