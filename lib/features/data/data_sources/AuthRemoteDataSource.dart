import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'package:cryphoria_mobile/features/domain/entities/login_response.dart';
import 'package:cryphoria_mobile/features/domain/entities/user_session.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(String username, String password, {String? deviceName, String? deviceId});
  Future<LoginResponse> register(String username, String password, String email, {String? deviceName, String? deviceId});
  
  // Session management
  Future<List<UserSession>> getSessions();
  Future<bool> approveSession(String sessionId);
  Future<bool> revokeSession(String sessionId);
  Future<bool> revokeOtherSessions();
  Future<bool> logout();
  Future<bool> confirmPassword(String password);
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
  Future<LoginResponse> register(String username, String password, String email, {String? deviceName, String? deviceId}) async {
    try {
      final data = {
        'username': username,
        'password': password,
        'email': email,
      };
      
      // Add device info to request body if provided (in addition to headers)
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

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return LoginResponse.fromJson(response.data);
      }
      
      throw ServerException(
        response.data['detail']?.toString() ?? 'Registration failed with status ${response.statusCode}'
      );
    } on DioException catch (e) {
      print('Register DioException: ${e.response?.statusCode} - ${e.response?.data}');
      final message = e.response?.data['detail']?.toString() ?? 'Registration failed'; 
      throw ServerException(message);
    }
  }

  @override
  Future<List<UserSession>> getSessions() async {
    try {
      final response = await dio.get('$baseUrl/api/auth/sessions/');
      
      if (response.statusCode == 200) {
        final sessions = (response.data['sessions'] as List)
            .map((session) => UserSession.fromJson(session))
            .toList();
        return sessions;
      }
      
      throw ServerException('Failed to fetch sessions');
    } on DioException catch (e) {
      final message = e.response?.data['detail']?.toString() ?? 'Failed to fetch sessions';
      throw ServerException(message);
    }
  }

  @override
  Future<bool> approveSession(String sessionId) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/auth/sessions/approve/',
        data: {'session_id': sessionId},
      );
      
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final message = e.response?.data['detail']?.toString() ?? 'Failed to approve session';
      throw ServerException(message);
    }
  }

  @override
  Future<bool> revokeSession(String sessionId) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/auth/sessions/revoke/',
        data: {'session_id': sessionId},
      );
      
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final message = e.response?.data['detail']?.toString() ?? 'Failed to revoke session';
      throw ServerException(message);
    }
  }

  @override
  Future<bool> revokeOtherSessions() async {
    try {
      final response = await dio.post('$baseUrl/api/auth/sessions/revoke-others/');
      
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final message = e.response?.data['detail']?.toString() ?? 'Failed to revoke other sessions';
      throw ServerException(message);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final response = await dio.post('$baseUrl/api/auth/logout/');
      
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final message = e.response?.data['detail']?.toString() ?? 'Logout failed';
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
}