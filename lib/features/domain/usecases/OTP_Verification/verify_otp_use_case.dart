import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

/// Use case for verifying OTP code.
/// It interacts with the [AuthRepository] to perform the OTP verification operation.
class VerifyOTP {
  final AuthRepository repository;
  VerifyOTP(this.repository);

  Future<bool> execute(String email, String code) {
    return repository.verifyOTP(email, code);
  }
}
