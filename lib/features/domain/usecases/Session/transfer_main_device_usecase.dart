import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

class TransferMainDevice {
  final AuthRepository repository;

  TransferMainDevice(this.repository);

  Future<bool> execute(String sessionId) {
    return repository.transferMainDevice(sessionId);
  }
}
