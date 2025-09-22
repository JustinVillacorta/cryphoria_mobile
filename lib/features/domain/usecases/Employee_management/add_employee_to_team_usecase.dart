import '../../entities/employee.dart';
import '../../repositories/employee_repository.dart';

class AddEmployeeToTeamUseCase {
  final EmployeeRepository repository;

  AddEmployeeToTeamUseCase({required this.repository});

  Future<Employee> execute(AddEmployeeToTeamRequest request) async {
    return await repository.addEmployeeToTeam(request);
  }
}