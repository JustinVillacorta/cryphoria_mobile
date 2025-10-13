import 'package:dio/dio.dart';

import '../../features/data/data_sources/AuthLocalDataSource.dart';

class DioClient {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  DioClient({
    required this.localDataSource, 
    Dio? dio
  }) : dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(milliseconds: 500000000),
              receiveTimeout: const Duration(milliseconds: 900000000),
            )) {
    this.dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Don't add auth token to login/register endpoints
        final isAuthEndpoint = options.path.contains('/api/auth/login/') || 
                               options.path.contains('/api/auth/register/');
        
        if (!isAuthEndpoint) {
          final token = await localDataSource.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 errors specifically for session-related issues
        if (error.response?.statusCode == 401) {
          final errorMessage = error.response?.data['detail']?.toString() ?? '';
          
          // Check for specific 401 error types based on backend contract
          if (errorMessage.contains('pending approval') || 
              errorMessage == 'Token is pending approval') {
            // Token is pending approval - don't clear token, just pass error through
            handler.next(error);
            return;
          } else if (errorMessage.contains('revoked') || 
                     errorMessage == 'Token has been revoked' ||
                     errorMessage.contains('Invalid token') ||
                     errorMessage == 'Invalid token' ||
                     errorMessage.contains('disabled') ||
                     errorMessage == 'User account is disabled') {
            // Token is invalid/revoked/disabled - clear cached token
            await localDataSource.clearAuthData();
          }
        }
        handler.next(error);
      },
    ));
    
    this.dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
      logPrint: (message) {
        print('DioClient Log: $message');
      },
    ));
  }
}
