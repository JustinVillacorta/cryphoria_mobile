import '../../repositories/auth_repository.dart';

class RevokeOtherSessions {
  final AuthRepository repository;

  RevokeOtherSessions(this.repository);

  Future<bool> execute() async {
    throw UnimplementedError('Revoke other sessions functionality is not available in the current backend API');
  }
}
