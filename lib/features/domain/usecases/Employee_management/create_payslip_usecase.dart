import '../../entities/employee.dart';
import '../../repositories/employee_repository.dart';

class CreatePayslipUseCase {
  final EmployeeRepository repository;

  CreatePayslipUseCase({required this.repository});

  Future<Payslip> execute(PayslipCreateRequest request) async {
    return await repository.createPayslip(request);
  }
}