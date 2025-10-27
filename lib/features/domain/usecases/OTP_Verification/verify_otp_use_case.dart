import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

class VerifyOTP {
  final AuthRepository repository;
  VerifyOTP(this.repository);

  Future<bool> execute(String email, String code) {
    return repository.verifyOTP(email, code);
  }
}