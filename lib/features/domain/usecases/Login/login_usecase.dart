
import 'package:cryphoria_mobile/features/domain/entities/login_response.dart';
import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

class Login {
  final AuthRepository repository;
  Login(this.repository);

  Future<LoginResponse> execute(String username, String password, {String? deviceName, String? deviceId}) {
    return repository.login(username, password, deviceName: deviceName, deviceId: deviceId);
  }
}