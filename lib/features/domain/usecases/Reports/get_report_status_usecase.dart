import '../../repositories/reports_repository.dart';

class GetReportStatusUseCase {
  final ReportsRepository repository;

  GetReportStatusUseCase(this.repository);

  Future<ReportStatus> execute(String reportId) async {
    return await repository.getReportStatus(reportId);
  }
}