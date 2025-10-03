import '../../repositories/reports_repository.dart';

class GenerateReportUseCase {
  final ReportsRepository repository;

  GenerateReportUseCase(this.repository);

  Future<String> execute(ReportGenerationRequest request) async {
    return await repository.generateReport(request);
  }
}