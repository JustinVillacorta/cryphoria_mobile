import '../../repositories/auth_repository.dart';

class RevokeOtherSessions {
  final AuthRepository repository;

  RevokeOtherSessions(this.repository);

  Future<bool> execute() async {
    return await repository.revokeOtherSessions();
  }
}
