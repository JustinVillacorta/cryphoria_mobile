import 'package:dio/dio.dart';
import '../../domain/repositories/reports_repository.dart';

abstract class ReportsRemoteDataSource {
  Future<String> generateReport(ReportGenerationRequest request);
  Future<ReportStatus> getReportStatus(String reportId);
  Future<ReportData> getReport(String reportId);
  Future<List<ReportData>> getUserReports();
  Future<String> downloadReport(String reportId);
  Future<void> emailReport(String reportId);
  Future<bool> deleteReport(String reportId);
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final Dio dio;

  ReportsRemoteDataSourceImpl({required this.dio});

  @override
  Future<String> generateReport(ReportGenerationRequest request) async {
    try {

      final response = await dio.post(
        '/api/reports/generate/',
        data: request.toJson(),
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        return responseData['report_id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString();
      } else {
        throw Exception('Failed to generate report: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<ReportStatus> getReportStatus(String reportId) async {
    try {

      final response = await dio.get('/api/reports/status/', queryParameters: {
        'report_id': reportId,
      });


      if (response.statusCode == 200) {
        return ReportStatus.fromJson(response.data);
      } else {
        throw Exception('Failed to get report status: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<ReportData> getReport(String reportId) async {
    try {

      final response = await dio.get('/api/reports/details/', queryParameters: {
        'report_id': reportId,
      });


      if (response.statusCode == 200) {
        return ReportData.fromJson(response.data);
      } else {
        throw Exception('Failed to get report: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<List<ReportData>> getUserReports() async {
    try {

      final response = await dio.get('/api/reports/list/');


      if (response.statusCode == 200) {
        final List<dynamic> reportsJson = response.data['reports'] ?? response.data['results'] ?? [];
        return reportsJson
            .map((json) => ReportData.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to get reports: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<String> downloadReport(String reportId) async {
    try {

      final response = await dio.get('/api/reports/download/', queryParameters: {
        'report_id': reportId,
      });


      if (response.statusCode == 200) {
        return response.data['download_url'] as String? ?? 'Download initiated';
      } else {
        throw Exception('Failed to download report: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<void> emailReport(String reportId) async {
    try {

      final response = await dio.post(
        '/api/reports/email/',
        data: {'report_id': reportId},
      );


      if (response.statusCode != 200) {
        throw Exception('Failed to email report: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<bool> deleteReport(String reportId) async {
    try {

      final response = await dio.delete('/api/reports/delete/', queryParameters: {
        'report_id': reportId,
      });


      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}