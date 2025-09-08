import 'package:cryphoria_mobile/features/domain/entities/user_session.dart';
import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

class GetTransferableSessions {
  final AuthRepository repository;

  GetTransferableSessions(this.repository);

  Future<List<UserSession>> execute() {
    return repository.getTransferableSessions();
  }
}
