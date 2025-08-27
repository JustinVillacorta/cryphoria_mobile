import '../../repositories/auth_repository.dart';
import '../../entities/user_session.dart';

class GetSessions {
  final AuthRepository repository;

  GetSessions(this.repository);

  Future<List<UserSession>> execute() async {
    return await repository.getSessions();
  }
}
