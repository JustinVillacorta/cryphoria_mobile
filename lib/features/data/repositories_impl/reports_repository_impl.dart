import '../../domain/repositories/reports_repository.dart';
import '../../domain/entities/tax_report.dart';
import '../../domain/entities/balance_sheet.dart';
import '../../domain/entities/cash_flow.dart';
import '../../domain/entities/portfolio.dart';
import '../../domain/entities/payslip.dart';
import '../../domain/entities/income_statement.dart';
import '../data_sources/reports_remote_data_source.dart';
import '../data_sources/audit_remote_data_source.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;
  final AuditRemoteDataSource auditRemoteDataSource;

  ReportsRepositoryImpl({
    required this.remoteDataSource,
    required this.auditRemoteDataSource,
  });

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


  @override
  Future<List<TaxReport>> getTaxReports() async {
    try {
      final taxReportModels = await auditRemoteDataSource.getTaxReports();

      final taxReports = taxReportModels.cast<TaxReport>();

      return taxReports;
    } catch (e) {
      throw Exception('Failed to get tax reports: $e');
    }
  }

  @override
  Future<List<BalanceSheet>> getAllBalanceSheets() async {
    try {
      final balanceSheetModels = await auditRemoteDataSource.getAllBalanceSheets();
      return balanceSheetModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get all balance sheets: $e');
    }
  }

  @override
  Future<CashFlowListResponse> getCashFlow() async {
    try {
      final cashFlowListResponseModel = await auditRemoteDataSource.getCashFlow();
      return cashFlowListResponseModel.toEntity();
    } catch (e) {
      throw Exception('Failed to get cash flow: $e');
    }
  }

  @override
  Future<Portfolio> getPortfolioValue() async {
    try {
      final portfolioModel = await auditRemoteDataSource.getPortfolioValue();
      return portfolioModel.toEntity();
    } catch (e) {
      throw Exception('Failed to get portfolio value: $e');
    }
  }

  @override
  Future<PayslipsResponse> getPayslips() async {
    try {
      final payslipsResponseModel = await auditRemoteDataSource.getPayslips();
      final entity = payslipsResponseModel.toEntity();
      return entity;
    } catch (e) {
      throw Exception('Failed to get payslips: $e');
    }
  }

  @override
  Future<List<IncomeStatement>> getIncomeStatements() async {
    try {
      final responseModel = await auditRemoteDataSource.getIncomeStatements();

      final incomeStatements = responseModel.incomeStatements.cast<IncomeStatement>();

      return incomeStatements;
    } catch (e) {
      throw Exception('Failed to get income statements: $e');
    }
  }
}