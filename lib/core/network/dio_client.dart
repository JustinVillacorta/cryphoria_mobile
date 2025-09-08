import 'package:dio/dio.dart';

import '../../features/data/data_sources/AuthLocalDataSource.dart';
import '../../features/data/services/device_info_service.dart';
import 'device_info_interceptor.dart';

class DioClient {
  final Dio dio;
  final AuthLocalDataSource localDataSource;
  final DeviceInfoService deviceInfoService;

  DioClient({
    required this.localDataSource, 
    required this.deviceInfoService,
    Dio? dio
  }) : dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            )) {
    // Add device info interceptor first (before auth interceptor)
    this.dio.interceptors.add(DeviceInfoInterceptor(deviceInfoService: deviceInfoService));
    
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
