import 'package:cryphoria_mobile/features/data/data_sources/AuthLocalDataSource.dart';
import 'package:cryphoria_mobile/features/data/data_sources/AuthRemoteDataSource.dart';
import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/entities/login_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<LoginResponse> login(String email, String password) async {
    final loginResponse = await remoteDataSource.login(email, password);
    await localDataSource.cacheAuthUser(loginResponse.data);
    return loginResponse;
  }

  @override
  Future<LoginResponse> register(String username, String password, String passwordConfirm, String email, String firstName, String lastName, String securityAnswer, {String? role}) async {
    final registerResponse = await remoteDataSource.register(username, password, passwordConfirm, email, firstName, lastName, securityAnswer, role: role);
    await localDataSource.cacheAuthUser(registerResponse.data);
    return registerResponse;
  }

  @override
  Future<bool> logout() async {
    final success = await remoteDataSource.logout();
    if (success) {
      await localDataSource.clearAuthData();
    }
    return success;
  }

  @override
  Future<bool> validateSession() async {
    return await remoteDataSource.validateSession();
  }

  @override
  Future<void> cacheAuthUser(AuthUser user) async {
    await localDataSource.cacheAuthUser(user);
  }

  @override
  Future<AuthUser?> getCachedAuthUser() async {
    return await localDataSource.getAuthUser();
  }

  @override
  Future<void> clearCache() async {
    await localDataSource.clearAuthData();
  }
}
