import '../../repositories/auth_repository.dart';

class RevokeSession {
  final AuthRepository repository;

  RevokeSession(this.repository);

  Future<bool> execute(String sessionId) async {
    return await repository.revokeSession(sessionId);
  }
}
