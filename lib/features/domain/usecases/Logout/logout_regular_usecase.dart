import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

/// Use case for regular logout
class LogoutRegular {
  final AuthRepository repository;
  LogoutRegular(this.repository);

  Future<bool> execute() {
    return repository.logout();
  }
}