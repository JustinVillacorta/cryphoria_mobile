import '../../repositories/auth_repository.dart';

class RevokeSession {
  final AuthRepository repository;

  RevokeSession(this.repository);

  Future<bool> execute(String sessionId) async {
    throw UnimplementedError('Revoke session functionality is not available in the current backend API');
  }
}
