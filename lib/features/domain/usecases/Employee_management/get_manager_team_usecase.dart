import '../../entities/employee.dart';
import '../../repositories/employee_repository.dart';

class GetManagerTeamUseCase {
  final EmployeeRepository repository;

  GetManagerTeamUseCase({required this.repository});

  Future<List<Employee>> execute() async {
    return await repository.getManagerTeam();
  }
}