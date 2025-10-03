import '../../repositories/reports_repository.dart';

class GetUserReportsUseCase {
  final ReportsRepository repository;

  GetUserReportsUseCase(this.repository);

  Future<List<ReportData>> execute() async {
    return await repository.getUserReports();
  }
}