import '../../entities/employee.dart';
import '../../repositories/employee_repository.dart';

class CreatePayrollEntryUseCase {
  final EmployeeRepository repository;

  CreatePayrollEntryUseCase({required this.repository});

  Future<PayrollInfo> execute(PayrollCreateRequest request) async {
    return await repository.createPayrollEntry(request);
  }
}