import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

/// Use case for resending OTP code.
/// It interacts with the [AuthRepository] to perform the OTP resend operation.
class ResendOTP {
  final AuthRepository repository;
  ResendOTP(this.repository);

  Future<void> execute(String email) {
    return repository.resendOTP(email);
  }
}
