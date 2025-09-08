import 'package:cryphoria_mobile/features/data/data_sources/AuthLocalDataSource.dart';
import 'package:cryphoria_mobile/features/data/data_sources/AuthRemoteDataSource.dart';
import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/entities/login_response.dart';
import '../../domain/entities/user_session.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<LoginResponse> login(String username, String password, {String? deviceName, String? deviceId}) async {
    final loginResponse = await remoteDataSource.login(username, password, deviceName: deviceName, deviceId: deviceId);
    await localDataSource.cacheAuthUser(loginResponse.data);
    return loginResponse;
  }

  @override
  Future<LoginResponse> register(String username, String password, String email, {String? role, String? deviceName, String? deviceId}) async {
    final registerResponse = await remoteDataSource.register(username, password, email, role: role, deviceName: deviceName, deviceId: deviceId);
    await localDataSource.cacheAuthUser(registerResponse.data);
    return registerResponse;
  }

  @override
  Future<Map<String, dynamic>> logoutCheck() async {
    return await remoteDataSource.logoutCheck();
  }

  @override
  Future<bool> logoutForce() async {
    final success = await remoteDataSource.logoutForce();
    if (success) {
      await localDataSource.clearAuthData();
    }
    return success;
  }

  @override
  Future<List<UserSession>> getTransferableSessions() async {
    return await remoteDataSource.getTransferableSessions();
  }

  @override
  Future<bool> transferMainDevice(String sessionId) async {
    return await remoteDataSource.transferMainDevice(sessionId);
  }

  @override
  Future<bool> confirmPassword(String password) async {
    return await remoteDataSource.confirmPassword(password);
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
