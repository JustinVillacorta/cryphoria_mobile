import '../../entities/employee.dart';
import '../../repositories/employee_repository.dart';

class GetAllEmployeesUseCase {
  final EmployeeRepository repository;

  GetAllEmployeesUseCase({required this.repository});

  Future<List<Employee>> execute() async {
    return await repository.getAllEmployees();
  }
}