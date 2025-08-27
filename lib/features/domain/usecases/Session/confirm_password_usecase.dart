import '../../repositories/auth_repository.dart';

class ConfirmPassword {
  final AuthRepository repository;

  ConfirmPassword(this.repository);

  Future<bool> execute(String password) async {
    return await repository.confirmPassword(password);
  }
}
