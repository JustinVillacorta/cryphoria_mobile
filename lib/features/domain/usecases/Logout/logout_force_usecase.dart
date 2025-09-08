import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

class LogoutForce {
  final AuthRepository repository;

  LogoutForce(this.repository);

  Future<bool> execute() {
    return repository.logoutForce();
  }
}
