import '../../repositories/auth_repository.dart';

class ApproveSession {
  final AuthRepository repository;

  ApproveSession(this.repository);

  Future<bool> execute(String sessionId) async {
    return await repository.approveSession(sessionId);
  }
}
