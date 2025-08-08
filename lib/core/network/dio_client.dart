import 'package:dio/dio.dart';

import '../../features/data/data_sources/AuthLocalDataSource.dart';

class DioClient {
  final Dio dio;
  final AuthLocalDataSource localDataSource;
  final void Function()? onUnauthorized;

  DioClient({required this.localDataSource, this.onUnauthorized, Dio? dio})
      : dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            )) {
    this.dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await localDataSource.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401 &&
            error.requestOptions.extra['refresh'] != true &&
            error.requestOptions.extra['retry'] != true) {
          final oldToken = await localDataSource.getToken();
          if (oldToken != null && oldToken.isNotEmpty) {
            try {
              final refreshResponse = await dio.post(
                '/api/auth/refresh/',
                options: Options(
                  headers: {'Authorization': 'Bearer $oldToken'},
                  extra: {'refresh': true},
                ),
              );
              final newToken = refreshResponse.data['token'];
              if (newToken != null) {
                await localDataSource.cacheToken(newToken);
                final response =
                    await _retry(error.requestOptions, newToken);
                return handler.resolve(response);
              }
            } catch (_) {
              // ignore and fall through to logout
            }
          }
          await localDataSource.cacheToken('');
          onUnauthorized?.call();
        }
        handler.next(error);
      },
    ));
  }

  Future<Response<dynamic>> _retry(
      RequestOptions requestOptions, String token) {
    final options = Options(
      method: requestOptions.method,
      headers: Map<String, dynamic>.from(requestOptions.headers)
        ..['Authorization'] = 'Bearer $token',
      extra: {'retry': true},
    );
    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
