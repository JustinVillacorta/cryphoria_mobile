import 'package:cryphoria_mobile/features/domain/entities/login_response.dart';
import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

/// Use case for registering a new user.
/// It interacts with the [AuthRepository] to perform the registration operation.
class Register {
  final AuthRepository repository;
  Register(this.repository);

  Future<LoginResponse> execute(String username, String password, String passwordConfirm, String email, String firstName, String lastName, String securityAnswer, {String? role}) {
    return repository.register(username, password, passwordConfirm, email, firstName, lastName, securityAnswer, role: role);
  }
}