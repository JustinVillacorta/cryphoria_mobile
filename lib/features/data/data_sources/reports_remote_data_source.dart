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
      print("📤 Generating report with request: ${request.toJson()}");

      final response = await dio.post(
        '/api/reports/generate/',
        data: request.toJson(),
      );

      print("📥 Generate report response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        return responseData['report_id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString();
      } else {
        throw Exception('Failed to generate report: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Error generating report: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<ReportStatus> getReportStatus(String reportId) async {
    try {
      print("📤 Getting report status for ID: $reportId");

      final response = await dio.get('/api/reports/status/', queryParameters: {
        'report_id': reportId,
      });

      print("📥 Report status response: ${response.data}");

      if (response.statusCode == 200) {
        return ReportStatus.fromJson(response.data);
      } else {
        throw Exception('Failed to get report status: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Error getting report status: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<ReportData> getReport(String reportId) async {
    try {
      print("📤 Getting report data for ID: $reportId");

      final response = await dio.get('/api/reports/details/', queryParameters: {
        'report_id': reportId,
      });

      print("📥 Report data response: ${response.data}");

      if (response.statusCode == 200) {
        return ReportData.fromJson(response.data);
      } else {
        throw Exception('Failed to get report: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Error getting report: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<List<ReportData>> getUserReports() async {
    try {
      print("📤 Getting user reports");

      final response = await dio.get('/api/reports/list/');

      print("📥 User reports response: ${response.data}");

      if (response.statusCode == 200) {
        final List<dynamic> reportsJson = response.data['reports'] ?? response.data['results'] ?? [];
        return reportsJson
            .map((json) => ReportData.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to get reports: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Error getting user reports: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<String> downloadReport(String reportId) async {
    try {
      print("📤 Downloading report for ID: $reportId");

      final response = await dio.get('/api/reports/download/', queryParameters: {
        'report_id': reportId,
      });

      print("📥 Download report response received");

      if (response.statusCode == 200) {
        // Assuming the response contains a download URL or file data
        return response.data['download_url'] as String? ?? 'Download initiated';
      } else {
        throw Exception('Failed to download report: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Error downloading report: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<void> emailReport(String reportId) async {
    try {
      print("📤 Emailing report for ID: $reportId");

      final response = await dio.post(
        '/api/reports/email/',
        data: {'report_id': reportId},
      );

      print("📥 Email report response: ${response.data}");

      if (response.statusCode != 200) {
        throw Exception('Failed to email report: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Error emailing report: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<bool> deleteReport(String reportId) async {
    try {
      print("📤 Deleting report for ID: $reportId");

      final response = await dio.delete('/api/reports/delete/', queryParameters: {
        'report_id': reportId,
      });

      print("📥 Delete report response: ${response.data}");

      return response.statusCode == 200;
    } on DioException catch (e) {
      print("❌ Error deleting report: $e");
      throw Exception('Network error: ${e.message}');
    }
  }
}