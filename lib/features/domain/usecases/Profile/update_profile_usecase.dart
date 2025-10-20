import '../../repositories/auth_repository.dart';

class UpdateProfile {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  Future<void> execute({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String company,
    required String department,
    required String securityQuestion,
    required String securityAnswer,
  }) {
    return repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      company: company,
      department: department,
      securityQuestion: securityQuestion,
      securityAnswer: securityAnswer,
    );
  }
}
