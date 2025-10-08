import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

/// Use case for requesting password reset.
/// It interacts with the [AuthRepository] to perform the password reset request operation.
class RequestPasswordReset {
  final AuthRepository repository;
  RequestPasswordReset(this.repository);

  Future<void> execute(String email) {
    return repository.requestPasswordReset(email);
  }
}
