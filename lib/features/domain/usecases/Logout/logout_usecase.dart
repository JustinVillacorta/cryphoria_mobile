import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

class Logout {
  final AuthRepository repository;
  Logout(this.repository);

  Future<bool> execute() {
    return repository.logout();
  }
}