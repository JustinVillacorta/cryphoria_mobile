import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> login(String username, String password);
  Future<AuthUser> register(String username, String password, String email);
}