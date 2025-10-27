import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

class ResetPassword {
  final AuthRepository repository;
  ResetPassword(this.repository);

  Future<void> execute(String email, String otp, String newPassword) {
    return repository.resetPassword(email, otp, newPassword);
  }
}