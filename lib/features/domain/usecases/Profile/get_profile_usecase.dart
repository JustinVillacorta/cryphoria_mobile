import '../../repositories/auth_repository.dart';

class GetProfile {
  final AuthRepository repository;

  GetProfile(this.repository);

  Future<Map<String, dynamic>> execute() {
    return repository.getProfile();
  }
}
