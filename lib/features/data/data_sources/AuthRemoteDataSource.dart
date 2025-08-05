import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<String> login(String username, String password);
  Future<String> register(String username, String password, String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  AuthRemoteDataSourceImpl({required this.dio, required this.baseUrl});

  @override
Future<String> login(String username, String password) async {
  try {
    final response = await dio.post(
      '$baseUrl/api/auth/login/',
      data: {'username': username, 'password': password},
    );
    print('Login response: ${response.data}'); // Debug print
    if (response.statusCode == 200 && response.data['token'] != null) {
      return response.data['token'];
    }
    throw ServerException(response.data['detail']?.toString() ?? 'Login failed');
  } on DioException catch (e) {
    final message = e.response?.data['detail']?.toString() ?? 'Login failed';
    throw ServerException(message);
  }
}
  @override
  Future<String> register(String username, String password, String email) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/auth/register/',
        data: {'username': username, 'password': password, 'email': email},
      );
      if (response.statusCode == 200) {
        return response.data['token'];
      }
      throw ServerException(response.data['detail']?.toString() ?? 'Registration failed');
    } on DioException catch (e) {
      final message = e.response?.data['detail']?.toString() ?? 'Registration failed';
      throw ServerException(message);
    }
  }
}
