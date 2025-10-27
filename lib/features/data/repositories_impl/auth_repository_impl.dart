
import 'package:cryphoria_mobile/features/data/data_sources/auth_local_data_source.dart';
import 'package:cryphoria_mobile/features/data/data_sources/auth_remote_data_source.dart';
import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/entities/login_response.dart';
import 'package:flutter/foundation.dart';

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
  Future<bool> verifyOTP(String email, String code) async {
    return await remoteDataSource.verifyOTP(email, code);
  }

  @override
  Future<void> resendOTP(String email) async {
    await remoteDataSource.resendOTP(email);
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await remoteDataSource.requestPasswordReset(email);
  }

  @override
  Future<void> resetPassword(String email, String otp, String newPassword) async {
    await remoteDataSource.resetPassword(email, otp, newPassword);
  }

  @override
  Future<void> resendPasswordReset(String email) async {
    await remoteDataSource.resendPasswordReset(email);
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
  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    debugPrint('🔐 [AUTH_REPO] Change password request received');
    debugPrint('🔐 [AUTH_REPO] Delegating to remote data source...');

    await remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    debugPrint('🔐 [AUTH_REPO] ✅ Password change completed successfully');
  }

  @override
  Future<AuthUser> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String company,
    required String department,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    debugPrint('👤 [AUTH_REPO] Profile update request received');
    debugPrint('👤 [AUTH_REPO] Delegating to remote data source...');

    final updatedUser = await remoteDataSource.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      company: company,
      department: department,
      securityQuestion: securityQuestion,
      securityAnswer: securityAnswer,
    );

    await localDataSource.cacheAuthUser(updatedUser);

    debugPrint('👤 [AUTH_REPO] ✅ Profile update completed successfully');
    return updatedUser;
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    return await remoteDataSource.getProfile();
  }
}


