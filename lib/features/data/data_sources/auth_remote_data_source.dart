import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'package:cryphoria_mobile/features/domain/entities/login_response.dart';
import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(String email, String password);
  Future<LoginResponse> register(String username, String password, String passwordConfirm, String email, String firstName, String lastName, String securityAnswer, {String? role});

  Future<bool> verifyOTP(String email, String code);
  Future<void> resendOTP(String email);

  Future<void> requestPasswordReset(String email);
  Future<void> resetPassword(String email, String otp, String newPassword);
  Future<void> resendPasswordReset(String email);

  Future<bool> logout();
  Future<bool> validateSession();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<AuthUser> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String company,
    required String department,
    required String securityQuestion,
    required String securityAnswer,
  });

  Future<Map<String, dynamic>> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  AuthRemoteDataSourceImpl({required this.dio, required this.baseUrl});

  @override
  Future<LoginResponse> login(String email, String password) async {
    try {
      final data = {
        'email': email,
        'password': password,
      };

      final response = await dio.post(
        '$baseUrl/api/auth/login/',
        data: data,
      );

      debugPrint('Login request data: $data');
      debugPrint('Login response code: ${response.statusCode}');
      debugPrint('Login response type: ${response.data.runtimeType}');
      debugPrint('Login response: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData == null) {
          throw ServerException('Empty response from server');
        }

        debugPrint('Response data type: ${responseData.runtimeType}');
        debugPrint('Response data content: $responseData');

        if (responseData is Map<String, dynamic>) {
          if (!responseData.containsKey('success') || !responseData.containsKey('user') || !responseData.containsKey('session_token')) {
            throw ServerException('Invalid response structure: missing success, user, or session_token fields');
          }

          final userData = responseData['user'];
          if (userData == null) {
            throw ServerException('Response user field is null');
          }

          if (userData is! Map<String, dynamic>) {
            throw ServerException('Response user field is not a Map: ${userData.runtimeType}');
          }

          final loginResponse = LoginResponse.fromJson(responseData);
          debugPrint('Login successful - User: ${loginResponse.data.email}');
          return loginResponse;
        } else {
          throw ServerException('Invalid response type: ${responseData.runtimeType}');
        }
      }

      final errorData = response.data;
      String errorMessage = 'Login failed';

      if (errorData is Map<String, dynamic>) {
        errorMessage = errorData['detail']?.toString() ?? 
                      errorData['error']?.toString() ?? 
                      errorData['message']?.toString() ?? 
                      'Login failed';
      } else if (errorData is String) {
        errorMessage = errorData;
      }

      throw ServerException(errorMessage);
    } on DioException catch (e) {
      debugPrint('DioException during login: ${e.message}');
      debugPrint('Response data: ${e.response?.data}');

      String errorMessage = 'Login failed';

      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['detail']?.toString() ?? 
                        errorData['error']?.toString() ?? 
                        errorData['message']?.toString() ?? 
                        'Login failed';
        } else if (errorData is String) {
          errorMessage = errorData;
        }
      } else {
        errorMessage = e.message ?? 'Network error during login';
      }

      throw ServerException(errorMessage);
    } catch (e) {
      debugPrint('Unexpected error during login: $e');
      throw ServerException('Unexpected error during login: ${e.toString()}');
    }
  }

  @override
  Future<LoginResponse> register(String username, String password, String passwordConfirm, String email, String firstName, String lastName, String securityAnswer, {String? role}) async {
    try {
      final data = {
        'username': username,
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
        'first_name': firstName,
        'last_name': lastName,
        'security_answer': securityAnswer,
        'role': role ?? 'Manager',
      };

      final response = await dio.post(
        '$baseUrl/api/auth/register/',
        data: data,
      );

      debugPrint('Register request data: $data');
      debugPrint('Register response code: ${response.statusCode}');
      debugPrint('Register response body: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final registerData = response.data;

        return LoginResponse.fromJson({
          'success': true,
          'message': registerData['message'] ?? 'Registration successful',
          'user': {
            'user_id': registerData['user_id'] ?? '',
            'username': registerData['username'] ?? '',
            'email': registerData['email'] ?? '',
            'role': registerData['role'] ?? 'Employee',
            'approved': true,
            'is_active': true,
          },
          'session_token': '',
        });
      }

      throw ServerException(
        response.data['error']?.toString() ?? 'Registration failed with status ${response.statusCode}'
      );
    } on DioException catch (e) {
      debugPrint('Register DioException: ${e.response?.statusCode} - ${e.response?.data}');
      final message = e.response?.data['error']?.toString() ?? 'Registration failed'; 
      throw ServerException(message);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final response = await dio.post('$baseUrl/api/auth/logout/');

      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint('Regular logout endpoint not implemented (404), considering local logout');
        return true;
      }
      final message = e.response?.data['detail']?.toString() ?? 'Logout failed';
      throw ServerException(message);
    }
  }



  @override
  Future<bool> validateSession() async {
    try {
      final response = await dio.get('$baseUrl/api/auth/sessions/validate/');

      return response.statusCode == 200;
    } on DioException catch (e) {
      final message = e.response?.data['detail']?.toString() ?? 'Session validation failed';
      throw ServerException(message);
    }
  }

  @override
  Future<bool> verifyOTP(String email, String code) async {
    try {
      final data = {
        'email': email,
        'code': code,
      };

      final response = await dio.post(
        '$baseUrl/api/auth/verify-email/',
        data: data,
      );

      debugPrint('Verify OTP request data: $data');
      debugPrint('Verify OTP response code: ${response.statusCode}');
      debugPrint('Verify OTP response body: ${response.data}');

      if (response.statusCode == 200) {
        return true;
      }

      throw ServerException(
        response.data['error']?.toString() ?? 'OTP verification failed with status ${response.statusCode}'
      );
    } on DioException catch (e) {
      debugPrint('Verify OTP DioException: ${e.response?.statusCode} - ${e.response?.data}');
      final message = e.response?.data['error']?.toString() ?? 
                     e.response?.data['detail']?.toString() ?? 
                     'OTP verification failed';
      throw ServerException(message);
    }
  }

  @override
  Future<void> resendOTP(String email) async {
    try {
      final data = {
        'email': email,
      };

      final response = await dio.post(
        '$baseUrl/api/auth/resend-otp/',
        data: data,
      );

      debugPrint('Resend OTP request data: $data');
      debugPrint('Resend OTP response code: ${response.statusCode}');
      debugPrint('Resend OTP response body: ${response.data}');

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['error']?.toString() ?? 'Failed to resend OTP with status ${response.statusCode}'
        );
      }
    } on DioException catch (e) {
      debugPrint('Resend OTP DioException: ${e.response?.statusCode} - ${e.response?.data}');
      final message = e.response?.data['error']?.toString() ?? 
                     e.response?.data['detail']?.toString() ?? 
                     'Failed to resend OTP';
      throw ServerException(message);
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      final data = {
        'email': email,
      };

      final response = await dio.post(
        '$baseUrl/api/auth/password-reset-request/',
        data: data,
      );

      debugPrint('Request password reset data: $data');
      debugPrint('Request password reset response code: ${response.statusCode}');
      debugPrint('Request password reset response body: ${response.data}');

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['error']?.toString() ?? 'Failed to request password reset with status ${response.statusCode}'
        );
      }
    } on DioException catch (e) {
      debugPrint('Request password reset DioException: ${e.response?.statusCode} - ${e.response?.data}');
      final message = e.response?.data['error']?.toString() ?? 
                     e.response?.data['detail']?.toString() ?? 
                     'Failed to request password reset';
      throw ServerException(message);
    }
  }

  @override
  Future<void> resetPassword(String email, String otp, String newPassword) async {
    try {
      final data = {
        'email': email,
        'otp': otp,
        'new_password': newPassword,
      };

      final response = await dio.post(
        '$baseUrl/api/auth/password-reset/',
        data: data,
      );

      debugPrint('Reset password data: $data');
      debugPrint('Reset password response code: ${response.statusCode}');
      debugPrint('Reset password response body: ${response.data}');

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['error']?.toString() ?? 'Password reset failed with status ${response.statusCode}'
        );
      }
    } on DioException catch (e) {
      debugPrint('Reset password DioException: ${e.response?.statusCode} - ${e.response?.data}');
      final message = e.response?.data['error']?.toString() ?? 
                     e.response?.data['detail']?.toString() ?? 
                     'Password reset failed';
      throw ServerException(message);
    }
  }

  @override
  Future<void> resendPasswordReset(String email) async {
    try {
      final data = {
        'email': email,
      };

      final response = await dio.post(
        '$baseUrl/api/auth/password-reset-request/',
        data: data,
      );

      debugPrint('Resend password reset data: $data');
      debugPrint('Resend password reset response code: ${response.statusCode}');
      debugPrint('Resend password reset response body: ${response.data}');

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['error']?.toString() ?? 'Failed to resend password reset with status ${response.statusCode}'
        );
      }
    } on DioException catch (e) {
      debugPrint('Resend password reset DioException: ${e.response?.statusCode} - ${e.response?.data}');
      final message = e.response?.data['error']?.toString() ?? 
                     e.response?.data['detail']?.toString() ?? 
                     'Failed to resend password reset';
      throw ServerException(message);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    debugPrint('🔐 [CHANGE_PASSWORD] Starting password change request');
    debugPrint('🔐 [CHANGE_PASSWORD] Endpoint: $baseUrl/api/auth/change-password/');

    try {
      final data = {
        'current_password': currentPassword,
        'new_password': newPassword,
      };

      debugPrint('🔐 [CHANGE_PASSWORD] Request data: $data');
      debugPrint('🔐 [CHANGE_PASSWORD] Making POST request...');

      final response = await dio.post(
        '$baseUrl/api/auth/change-password/',
        data: data,
      );

      debugPrint('🔐 [CHANGE_PASSWORD] ✅ Response received');
      debugPrint('🔐 [CHANGE_PASSWORD] Status code: ${response.statusCode}');
      debugPrint('🔐 [CHANGE_PASSWORD] Response headers: ${response.headers}');
      debugPrint('🔐 [CHANGE_PASSWORD] Response data: ${response.data}');

      if (response.statusCode != 200) {
        debugPrint('🔐 [CHANGE_PASSWORD] ❌ Non-200 status code: ${response.statusCode}');
        throw ServerException(
          response.data['error']?.toString() ?? 
          response.data['detail']?.toString() ?? 
          'Password change failed with status ${response.statusCode}'
        );
      }

      debugPrint('🔐 [CHANGE_PASSWORD] ✅ Password change successful!');
    } on DioException catch (e) {
      debugPrint('🔐 [CHANGE_PASSWORD] ❌ DioException occurred');
      debugPrint('🔐 [CHANGE_PASSWORD] Error type: ${e.type}');
      debugPrint('🔐 [CHANGE_PASSWORD] Error message: ${e.message}');
      debugPrint('🔐 [CHANGE_PASSWORD] Response status: ${e.response?.statusCode}');
      debugPrint('🔐 [CHANGE_PASSWORD] Response data: ${e.response?.data}');

      final message = e.response?.data['error']?.toString() ?? 
                     e.response?.data['detail']?.toString() ?? 
                     'Password change failed';
      debugPrint('🔐 [CHANGE_PASSWORD] Throwing ServerException: $message');
      throw ServerException(message);
    } catch (e) {
      debugPrint('🔐 [CHANGE_PASSWORD] ❌ Unexpected error: $e');
      debugPrint('🔐 [CHANGE_PASSWORD] Error type: ${e.runtimeType}');
      throw ServerException('Unexpected error during password change: ${e.toString()}');
    }
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
    debugPrint('👤 [UPDATE_PROFILE] Starting profile update request');
    debugPrint('👤 [UPDATE_PROFILE] Endpoint: $baseUrl/api/auth/profile-mongodb/');

    try {
      final data = {
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'company': company,
        'department': department,
        'security_question': securityQuestion,
        'security_answer': securityAnswer,
      };

      debugPrint('👤 [UPDATE_PROFILE] Request data: $data');
      debugPrint('👤 [UPDATE_PROFILE] Making PUT request...');

      final response = await dio.put(
        '$baseUrl/api/auth/profile-mongodb/',
        data: data,
      );

      debugPrint('👤 [UPDATE_PROFILE] ✅ Response received');
      debugPrint('👤 [UPDATE_PROFILE] Status code: ${response.statusCode}');
      debugPrint('👤 [UPDATE_PROFILE] Response headers: ${response.headers}');
      debugPrint('👤 [UPDATE_PROFILE] Response data: ${response.data}');

      if (response.statusCode != 200) {
        debugPrint('👤 [UPDATE_PROFILE] ❌ Non-200 status code: ${response.statusCode}');
        throw ServerException(
          response.data['error']?.toString() ?? 
          response.data['detail']?.toString() ?? 
          'Profile update failed with status ${response.statusCode}'
        );
      }

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final updatedUser = AuthUser.fromJson(responseData);
        debugPrint('👤 [UPDATE_PROFILE] ✅ Profile update successful!');
        return updatedUser;
      } else {
        throw ServerException('Invalid response format from profile update');
      }
    } on DioException catch (e) {
      debugPrint('👤 [UPDATE_PROFILE] ❌ DioException occurred');
      debugPrint('👤 [UPDATE_PROFILE] Error type: ${e.type}');
      debugPrint('👤 [UPDATE_PROFILE] Error message: ${e.message}');
      debugPrint('👤 [UPDATE_PROFILE] Response status: ${e.response?.statusCode}');
      debugPrint('👤 [UPDATE_PROFILE] Response data: ${e.response?.data}');

      final message = e.response?.data['error']?.toString() ?? 
                     e.response?.data['detail']?.toString() ?? 
                     'Profile update failed';
      debugPrint('👤 [UPDATE_PROFILE] Throwing ServerException: $message');
      throw ServerException(message);
    } catch (e) {
      debugPrint('👤 [UPDATE_PROFILE] ❌ Unexpected error: $e');
      debugPrint('👤 [UPDATE_PROFILE] Error type: ${e.runtimeType}');
      throw ServerException('Unexpected error during profile update: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      debugPrint('👤 [GET_PROFILE] Fetching user profile...');
      debugPrint('👤 [GET_PROFILE] Endpoint: $baseUrl/api/auth/profile-mongodb/');

      final response = await dio.get('$baseUrl/api/auth/profile-mongodb/');

      debugPrint('👤 [GET_PROFILE] ✅ Response received');
      debugPrint('👤 [GET_PROFILE] Status code: ${response.statusCode}');
      debugPrint('👤 [GET_PROFILE] Response data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data;
      }

      throw ServerException('Failed to fetch profile with status ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('👤 [GET_PROFILE] ❌ DioException occurred');
      debugPrint('👤 [GET_PROFILE] Error type: ${e.type}');
      debugPrint('👤 [GET_PROFILE] Error message: ${e.message}');
      debugPrint('👤 [GET_PROFILE] Response status: ${e.response?.statusCode}');
      debugPrint('👤 [GET_PROFILE] Response data: ${e.response?.data}');

      final message = e.response?.data['error']?.toString() ?? 
                     e.response?.data['detail']?.toString() ?? 
                     'Failed to fetch profile';
      throw ServerException(message);
    } catch (e) {
      debugPrint('👤 [GET_PROFILE] ❌ Unexpected error: $e');
      throw ServerException('Unexpected error during profile fetch: ${e.toString()}');
    }
  }
}

