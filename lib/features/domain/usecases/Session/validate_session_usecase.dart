import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

/// Use case for validating the current session.
/// It interacts with the [AuthRepository] to validate the user's session token.
class ValidateSession {
  final AuthRepository repository;
  ValidateSession(this.repository);

  Future<bool> execute() {
    return repository.validateSession();
  }
}
