import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

/// Use case for registering a new user.
/// It interacts with the [AuthRepository] to perform the registration operation.
class Register {
  final AuthRepository repository;
  Register(this.repository);

  Future<AuthUser> execute(String username, String password, String email) {
    return repository.register(username, password, email);
  }
}