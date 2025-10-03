import '../../domain/repositories/reports_repository.dart';
import '../data_sources/reports_remote_data_source.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;

  ReportsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> generateReport(ReportGenerationRequest request) async {
    return await remoteDataSource.generateReport(request);
  }

  @override
  Future<ReportStatus> getReportStatus(String reportId) async {
    return await remoteDataSource.getReportStatus(reportId);
  }

  @override
  Future<ReportData> getReport(String reportId) async {
    return await remoteDataSource.getReport(reportId);
  }

  @override
  Future<List<ReportData>> getUserReports() async {
    return await remoteDataSource.getUserReports();
  }

  @override
  Future<String> downloadReport(String reportId) async {
    return await remoteDataSource.downloadReport(reportId);
  }

  @override
  Future<void> emailReport(String reportId) async {
    return await remoteDataSource.emailReport(reportId);
  }

  @override
  Future<bool> deleteReport(String reportId) async {
    return await remoteDataSource.deleteReport(reportId);
  }
}