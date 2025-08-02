import 'package:cryphoria_mobile/core/error/excemptions.dart';
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
      if (response.statusCode == 200) {
        return response.data['token'];
      } else {
        throw ServerException();
      }
    } on DioError catch (_) {
      throw ServerException();
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
      } else {
        throw ServerException();
      }
    } on DioError catch (_) {
      throw ServerException();
    }
  }
}