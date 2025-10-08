import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'package:cryphoria_mobile/features/domain/entities/login_response.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(String email, String password);
  Future<LoginResponse> register(String username, String password, String passwordConfirm, String email, String firstName, String lastName, String securityAnswer, {String? role});
  
  // OTP verification
  Future<bool> verifyOTP(String email, String code);
  Future<void> resendOTP(String email);
  
  // Password reset
  Future<void> requestPasswordReset(String email);
  Future<void> resetPassword(String email, String otp, String newPassword);
  Future<void> resendPasswordReset(String email);
  
  // Basic authentication
  Future<bool> logout();
  Future<bool> validateSession();
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
      
      print('Login request data: $data');
      print('Login response code: ${response.statusCode}');
      print('Login response type: ${response.data.runtimeType}');
      print('Login response: ${response.data}');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData == null) {
          throw ServerException('Empty response from server');
        }
        
        print('Response data type: ${responseData.runtimeType}');
        print('Response data content: $responseData');
        
        if (responseData is Map<String, dynamic>) {
          // Check if the response has the expected structure for new backend format
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
          
          // The backend returns the new format: {"success": true, "message": "...", "user": {...}, "session_token": "..."}
          final loginResponse = LoginResponse.fromJson(responseData);
          print('Login successful - User: ${loginResponse.data.email}');
          return loginResponse;
        } else {
          throw ServerException('Invalid response type: ${responseData.runtimeType}');
        }
      }
      
      // Handle error responses
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
      print('DioException during login: ${e.message}');
      print('Response data: ${e.response?.data}');
      
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
      print('Unexpected error during login: $e');
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
        'role': role ?? 'Manager', // Default to Manager as per new backend
      };
      
      final response = await dio.post(
        '$baseUrl/api/auth/register/',
        data: data,
      );
      
      print('Register request data: $data');
      print('Register response code: ${response.statusCode}');
      print('Register response body: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registration successful, return user data
        // Note: Backend returns different format for register vs login
        // Registration response doesn't include token/session data, so we need to create a mock AuthUser
        final registerData = response.data;
        
        return LoginResponse.fromJson({
          'success': true,
          'message': registerData['message'] ?? 'Registration successful',
          'user': {
            'user_id': registerData['user_id'] ?? '',
            'username': registerData['username'] ?? '',
            'email': registerData['email'] ?? '',
            'role': registerData['role'] ?? 'Employee',
            'approved': true, // Registration is automatically approved since we removed approval logic
            'is_active': true,
          },
          'session_token': '', // Empty token since registration doesn't log user in
        });
      }
      
      throw ServerException(
        response.data['error']?.toString() ?? 'Registration failed with status ${response.statusCode}'
      );
    } on DioException catch (e) {
      print('Register DioException: ${e.response?.statusCode} - ${e.response?.data}');
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
      // If endpoint not found, just clear local data
      if (e.response?.statusCode == 404) {
        print('Regular logout endpoint not implemented (404), considering local logout');
        return true; // Allow local logout even if backend doesn't support it
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
      
      print('Verify OTP request data: $data');
      print('Verify OTP response code: ${response.statusCode}');
      print('Verify OTP response body: ${response.data}');

      if (response.statusCode == 200) {
        return true;
      }
      
      throw ServerException(
        response.data['error']?.toString() ?? 'OTP verification failed with status ${response.statusCode}'
      );
    } on DioException catch (e) {
      print('Verify OTP DioException: ${e.response?.statusCode} - ${e.response?.data}');
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
      
      print('Resend OTP request data: $data');
      print('Resend OTP response code: ${response.statusCode}');
      print('Resend OTP response body: ${response.data}');

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['error']?.toString() ?? 'Failed to resend OTP with status ${response.statusCode}'
        );
      }
    } on DioException catch (e) {
      print('Resend OTP DioException: ${e.response?.statusCode} - ${e.response?.data}');
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
      
      print('Request password reset data: $data');
      print('Request password reset response code: ${response.statusCode}');
      print('Request password reset response body: ${response.data}');

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['error']?.toString() ?? 'Failed to request password reset with status ${response.statusCode}'
        );
      }
    } on DioException catch (e) {
      print('Request password reset DioException: ${e.response?.statusCode} - ${e.response?.data}');
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
      
      print('Reset password data: $data');
      print('Reset password response code: ${response.statusCode}');
      print('Reset password response body: ${response.data}');

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['error']?.toString() ?? 'Password reset failed with status ${response.statusCode}'
        );
      }
    } on DioException catch (e) {
      print('Reset password DioException: ${e.response?.statusCode} - ${e.response?.data}');
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
      
      print('Resend password reset data: $data');
      print('Resend password reset response code: ${response.statusCode}');
      print('Resend password reset response body: ${response.data}');

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['error']?.toString() ?? 'Failed to resend password reset with status ${response.statusCode}'
        );
      }
    } on DioException catch (e) {
      print('Resend password reset DioException: ${e.response?.statusCode} - ${e.response?.data}');
      final message = e.response?.data['error']?.toString() ?? 
                     e.response?.data['detail']?.toString() ?? 
                     'Failed to resend password reset';
      throw ServerException(message);
    }
  }
}