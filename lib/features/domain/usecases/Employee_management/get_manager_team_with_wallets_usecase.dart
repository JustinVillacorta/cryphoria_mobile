import '../../entities/employee.dart';
import '../../repositories/employee_repository.dart';

class GetManagerTeamWithWalletsUseCase {
  final EmployeeRepository repository;

  GetManagerTeamWithWalletsUseCase({required this.repository});

  Future<List<Employee>> execute() async {
    return await repository.getManagerTeamWithWallets();
  }
}
