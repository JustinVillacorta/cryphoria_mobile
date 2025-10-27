
import '../../repositories/employee_repository.dart';

class RemoveEmployeeFromTeamUseCase {
  final EmployeeRepository repository;

  RemoveEmployeeFromTeamUseCase({required this.repository});

  Future<void> execute(String email) async {
    if (email.isEmpty) {
      throw Exception('Email is required');
    }

    if (!email.contains('@') || !email.contains('.')) {
      throw Exception('Invalid email format');
    }

    return await repository.removeEmployeeFromTeam(email);
  }
}