import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

class RequestPasswordReset {
  final AuthRepository repository;
  RequestPasswordReset(this.repository);

  Future<void> execute(String email) {
    return repository.requestPasswordReset(email);
  }
}