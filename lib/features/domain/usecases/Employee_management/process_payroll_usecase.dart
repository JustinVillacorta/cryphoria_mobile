import '../../repositories/employee_repository.dart';

class ProcessPayrollUseCase {
  final EmployeeRepository repository;

  ProcessPayrollUseCase({required this.repository});

  Future<PayrollBatchResult> execute(PayrollBatchRequest request) async {
    return await repository.processBatchPayroll(request);
  }
}