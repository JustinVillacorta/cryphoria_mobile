import 'package:dio/dio.dart';

import '../../features/data/data_sources/AuthLocalDataSource.dart';

class DioClient {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  DioClient({required this.localDataSource, Dio? dio})
      : dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            )) {
    this.dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      final token = await localDataSource.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    }));
  }
}
