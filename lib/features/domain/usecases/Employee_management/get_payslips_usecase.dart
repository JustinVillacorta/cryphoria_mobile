import '../../entities/employee.dart';
import '../../repositories/employee_repository.dart';

class GetPayslipsUseCase {
  final EmployeeRepository repository;

  GetPayslipsUseCase({required this.repository});

  Future<List<Payslip>> execute({String? employeeId, String? status}) async {
    return await repository.getPayslips(employeeId: employeeId, status: status);
  }
}