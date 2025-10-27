import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

class ResendPasswordReset {
  final AuthRepository repository;
  ResendPasswordReset(this.repository);

  Future<void> execute(String email) {
    return repository.resendPasswordReset(email);
  }
}