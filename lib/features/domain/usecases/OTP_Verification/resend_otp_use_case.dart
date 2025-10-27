import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

class ResendOTP {
  final AuthRepository repository;
  ResendOTP(this.repository);

  Future<void> execute(String email) {
    return repository.resendOTP(email);
  }
}