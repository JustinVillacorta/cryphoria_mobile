// lib/features/domain/usecases/Employee_management/remove_employee_from_team_usecase.dart

import '../../repositories/employee_repository.dart';

class RemoveEmployeeFromTeamUseCase {
  final EmployeeRepository repository;

  RemoveEmployeeFromTeamUseCase({required this.repository});

  Future<void> execute(String email) async {
    // Validate input
    if (email.isEmpty) {
      throw Exception('Email is required');
    }

    // Basic email validation
    if (!email.contains('@') || !email.contains('.')) {
      throw Exception('Invalid email format');
    }

    return await repository.removeEmployeeFromTeam(email);
  }
}
