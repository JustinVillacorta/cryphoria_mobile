import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

class LogoutCheck {
  final AuthRepository repository;

  LogoutCheck(this.repository);

  Future<Map<String, dynamic>> execute() {
    return repository.logoutCheck();
  }
}
