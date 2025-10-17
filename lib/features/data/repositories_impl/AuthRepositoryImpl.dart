
import 'package:dio/dio.dart';

import 'package:cryphoria_mobile/features/data/data_sources/AuthLocalDataSource.dart';
import 'package:cryphoria_mobile/features/data/data_sources/AuthRemoteDataSource.dart';
import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/entities/login_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final Dio _dio = Dio();

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
  try {
    final response = await _dio.post(
      '/api/change_password/',
      data: <String, dynamic>{
        // Common DRF expectations; uses current/new naming
        'current_password': currentPassword,
        'new_password': newPassword,
      },
      options: Options(
        headers: {
          // If your client already injects this, you can remove this header.
          'Content-Type': 'application/json',
        },
      ),
    );

    // Accept 200 or 204 as success; adjust if your API differs
    final code = response.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      throw Exception('Failed to change password (${response.statusCode}).');
    }
  } on DioException catch (e) {
    // Extract DRF error details if present
    final data = e.response?.data;
    String message = 'Failed to change password';
    if (data is Map) {
      if (data['error'] is String) {
        message = data['error'] as String; // e.g. "Invalid JSON format"
      } else if (data['detail'] is String) {
        message = data['detail'] as String;
      }
    }
    // Fall back to Dio message if nothing else
    message = message.isNotEmpty ? message : (e.message ?? message);
    throw Exception(message);
  } catch (e) {
    throw Exception(e.toString());
  }
}
}