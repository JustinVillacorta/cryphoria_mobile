import 'package:cryphoria_mobile/features/domain/entities/login_response.dart';
import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

class Register {
  final AuthRepository repository;
  Register(this.repository);

  Future<LoginResponse> execute(String username, String password, String passwordConfirm, String email, String firstName, String lastName, String securityAnswer, {String? role}) {
    return repository.register(username, password, passwordConfirm, email, firstName, lastName, securityAnswer, role: role);
  }
}