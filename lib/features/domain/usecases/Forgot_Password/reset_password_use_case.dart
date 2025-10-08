import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

/// Use case for resetting password with OTP.
/// It interacts with the [AuthRepository] to perform the password reset operation.
class ResetPassword {
  final AuthRepository repository;
  ResetPassword(this.repository);

  Future<void> execute(String email, String otp, String newPassword) {
    return repository.resetPassword(email, otp, newPassword);
  }
}
