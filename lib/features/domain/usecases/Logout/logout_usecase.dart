import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

/// Use case for logging out the current user.
/// It interacts with the [AuthRepository] to perform the logout operation.
class Logout {
  final AuthRepository repository;
  Logout(this.repository);

  Future<bool> execute() {
    return repository.logout();
  }
}
