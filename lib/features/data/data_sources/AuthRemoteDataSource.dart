import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'package:cryphoria_mobile/features/domain/entities/login_response.dart';
import 'package:cryphoria_mobile/features/domain/entities/user_session.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(String username, String password, {String? deviceName, String? deviceId});
  Future<LoginResponse> register(String username, String password, String email, {String? role, String? deviceName, String? deviceId});
  
  // Session management - aligned with backend API
  Future<bool> logout(); // Regular logout
  Future<Map<String, dynamic>> logoutCheck(); // Check if safe logout is possible
  Future<bool> logoutForce(); // Force logout without transfer check
  Future<List<UserSession>> getTransferableSessions(); // List transferable sessions
  Future<bool> transferMainDevice(String sessionId); // Transfer main device privileges
  Future<bool> confirmPassword(String password);
  Future<bool> validateSession(); // Session validation endpoint
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  AuthRemoteDataSourceImpl({required this.dio, required this.baseUrl});

  @override
  Future<LoginResponse> login(String username, String password, {String? deviceName, String? deviceId}) async {
    try {
      final data = {
        'username': username,
        'password': password,
      };
      
      // Add device info to request body if provided (in addition to headers)
      if (deviceName != null) {
        data['device_name'] = deviceName;
      }
      if (deviceId != null) {
        data['device_id'] = deviceId;
      }
      
      final response = await dio.post(
        '$baseUrl/api/auth/login/',
        data: data,
      );
      
      print('Login request data: $data');
      print('Login response code: ${response.statusCode}');
      print('Login response: ${response.data}');
      
      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        print('Login successful - User approved: ${loginResponse.data.approved}');
        return loginResponse;
      }
      
      throw ServerException(response.data['detail']?.toString() ?? 'Login failed');
    } on DioException catch (e) {
      final message = e.response?.data['detail']?.toString() ?? 'Login failed';
      throw ServerException(message);
    }
  }

  @override
  Future<LoginResponse> register(String username, String password, String email, {String? role, String? deviceName, String? deviceId}) async {
    try {
      final data = {
        'username': username,
        'password': password,
        'email': email,
      };
      
      // Add role if provided (defaults to "Employee" as per backend)
      if (role != null) {
        data['role'] = role;
      }
      
      // Add device info to request body if provided
      if (deviceName != null) {
        data['device_name'] = deviceName;
      }
      if (deviceId != null) {
        data['device_id'] = deviceId;
      }
      
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
          'data': {
            'user_id': registerData['user_id'] ?? '',
            'username': registerData['username'] ?? '',
            'email': registerData['email'] ?? '',
            'role': registerData['role'] ?? 'Employee',
            // Mock auth fields since registration doesn't return these
            'token': '', // Empty token since registration doesn't log user in
            'session_id': '',
            'approved': false, // User needs to login to get real auth status
            'is_active': true,
            'token_created_at': DateTime.now().toIso8601String(),
          }
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
  Future<Map<String, dynamic>> logoutCheck() async {
    try {
      final response = await dio.post('$baseUrl/api/auth/logout/check/');
      
      if (response.statusCode == 200) {
        return response.data;
      }
      
      throw ServerException('Logout check failed');
    } on DioException catch (e) {
      final message = e.response?.data['detail']?.toString() ?? 'Logout check failed';
      throw ServerException(message);
    }
  }

  @override
  Future<bool> logoutForce() async {
    try {
      final response = await dio.post('$baseUrl/api/auth/logout/force/');
      
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      // If endpoint not found, just clear local data
      if (e.response?.statusCode == 404) {
        print('Force logout endpoint not implemented (404), considering local logout');
        return true; // Allow local logout even if backend doesn't support it
      }
      final message = e.response?.data['detail']?.toString() ?? 'Force logout failed';
      throw ServerException(message);
    }
  }

  @override
  Future<List<UserSession>> getTransferableSessions() async {
    try {
      final response = await dio.get('$baseUrl/api/auth/sessions/');
      
      if (response.statusCode == 200) {
        final sessions = (response.data['sessions'] as List)
            .map((session) => UserSession.fromJson(session))
            .toList();
        return sessions;
      }
      
      throw ServerException('Failed to fetch transferable sessions');
    } on DioException catch (e) {
      final message = e.response?.data['detail']?.toString() ?? 'Failed to fetch transferable sessions';
      throw ServerException(message);
    }
  }

  @override
  Future<bool> transferMainDevice(String sessionId) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/auth/sessions/approve/',
        data: {'session_id': sessionId},
      );
      
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final message = e.response?.data['detail']?.toString() ?? 'Failed to transfer main device';
      throw ServerException(message);
    }
  }

  @override
  Future<bool> confirmPassword(String password) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/auth/confirm-password/',
        data: {'password': password},
      );
      
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final message = e.response?.data['detail']?.toString() ?? 'Password confirmation failed';
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
}