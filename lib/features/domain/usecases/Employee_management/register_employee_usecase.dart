import '../../entities/employee.dart';
import '../../repositories/employee_repository.dart';

class RegisterEmployeeUseCase {
  final EmployeeRepository repository;

  RegisterEmployeeUseCase({required this.repository});

  Future<Employee> execute(EmployeeRegistrationRequest request) async {
    return await repository.registerEmployee(request);
  }
}