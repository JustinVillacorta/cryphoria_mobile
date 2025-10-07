import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

/// Use case for resending password reset code.
/// It interacts with the [AuthRepository] to perform the resend password reset operation.
class ResendPasswordReset {
  final AuthRepository repository;
  ResendPasswordReset(this.repository);

  Future<void> execute(String email) {
    return repository.resendPasswordReset(email);
  }
}
