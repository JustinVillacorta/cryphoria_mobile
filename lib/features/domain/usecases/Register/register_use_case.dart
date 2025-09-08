import 'package:cryphoria_mobile/features/domain/entities/login_response.dart';
import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

/// Use case for registering a new user.
/// It interacts with the [AuthRepository] to perform the registration operation.
class Register {
  final AuthRepository repository;
  Register(this.repository);

  Future<LoginResponse> execute(String username, String password, String email, {String? role, String? deviceName, String? deviceId}) {
    return repository.register(username, password, email, role: role, deviceName: deviceName, deviceId: deviceId);
  }
}