import 'package:dio/dio.dart';

import '../../features/data/data_sources/auth_local_data_source.dart';

class DioClient {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  DioClient({
    required this.localDataSource, 
    required this.dio,
  }) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final isAuthEndpoint = options.path.contains('/api/auth/login/') || 
                               options.path.contains('/api/auth/register/');

        if (!isAuthEndpoint) {
          final authUser = await localDataSource.getAuthUser();
          if (authUser != null && authUser.token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${authUser.token}';
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final errorMessage = error.response?.data['detail']?.toString() ?? '';

          if (errorMessage.contains('pending approval') || 
              errorMessage == 'Token is pending approval') {
            handler.next(error);
            return;
          } else if (errorMessage.contains('revoked') || 
                     errorMessage == 'Token has been revoked' ||
                     errorMessage.contains('Invalid token') ||
                     errorMessage == 'Invalid token' ||
                     errorMessage.contains('disabled') ||
                     errorMessage == 'User account is disabled') {
            await localDataSource.clearAuthData();
          }
        }
        handler.next(error);
      },
    ));

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
      logPrint: (message) {
      },
    ));
  }
}