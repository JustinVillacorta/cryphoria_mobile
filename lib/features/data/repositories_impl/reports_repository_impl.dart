import '../../domain/repositories/reports_repository.dart';
import '../../domain/entities/tax_report.dart';
import '../../domain/entities/balance_sheet.dart';
import '../../domain/entities/cash_flow.dart';
import '../../domain/entities/portfolio.dart';
import '../../domain/entities/payslip.dart';
import '../../domain/entities/income_statement.dart';
import '../../domain/entities/investment_report.dart';
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

  // Financial Reports Implementation

  @override
  Future<List<TaxReport>> getTaxReports() async {
    try {
      print("🔄 ReportsRepositoryImpl: Getting tax reports from auditRemoteDataSource");
      final taxReportModels = await auditRemoteDataSource.getTaxReports();
      print("📥 ReportsRepositoryImpl: Received ${taxReportModels.length} tax report models");
      
      // TaxReportModel extends TaxReport, so no conversion needed
      final taxReports = taxReportModels.cast<TaxReport>();
      print("✅ ReportsRepositoryImpl: Successfully cast ${taxReports.length} tax reports to entities");
      
      return taxReports;
    } catch (e, stackTrace) {
      print("❌ ReportsRepositoryImpl: Error getting tax reports: $e");
      print("📄 Stack trace: $stackTrace");
      throw Exception('Failed to get tax reports: $e');
    }
  }

  @override
  Future<BalanceSheet> getBalanceSheet() async {
    try {
      final balanceSheetModel = await auditRemoteDataSource.getBalanceSheet();
      return balanceSheetModel.toEntity();
    } catch (e) {
      throw Exception('Failed to get balance sheet: $e');
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
  Future<CashFlow> getCashFlow() async {
    try {
      return await auditRemoteDataSource.getCashFlow();
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
      print("🔄 ReportsRepositoryImpl: Getting payslips from auditRemoteDataSource");
      final payslipsResponseModel = await auditRemoteDataSource.getPayslips();
      print("📥 ReportsRepositoryImpl: Received payslips response model with ${payslipsResponseModel.payslips.length} payslips");
      final entity = payslipsResponseModel.toEntity();
      print("✅ ReportsRepositoryImpl: Successfully converted to entity");
      return entity;
    } catch (e, stackTrace) {
      print("❌ ReportsRepositoryImpl: Error getting payslips: $e");
      print("📄 Stack trace: $stackTrace");
      throw Exception('Failed to get payslips: $e');
    }
  }

  @override
  Future<List<IncomeStatement>> getIncomeStatements() async {
    try {
      print("🔄 ReportsRepositoryImpl: Getting income statements from auditRemoteDataSource");
      final responseModel = await auditRemoteDataSource.getIncomeStatements();
      print("📥 ReportsRepositoryImpl: Received ${responseModel.incomeStatements.length} income statement models");
      
      // Convert models to entities
      final incomeStatements = responseModel.incomeStatements.cast<IncomeStatement>();
      print("✅ ReportsRepositoryImpl: Successfully converted ${incomeStatements.length} income statements to entities");
      
      return incomeStatements;
    } catch (e, stackTrace) {
      print("❌ ReportsRepositoryImpl: Error getting income statements: $e");
      print("📄 Stack trace: $stackTrace");
      throw Exception('Failed to get income statements: $e');
    }
  }

  @override
  Future<List<InvestmentReport>> getInvestmentReports() async {
    try {
      print("🔄 ReportsRepositoryImpl: Getting investment reports from auditRemoteDataSource");
      final responseModel = await auditRemoteDataSource.getInvestmentReports();
      print("📥 ReportsRepositoryImpl: Received ${responseModel.investmentReports.length} investment report models");
      
      // Convert models to entities
      final investmentReports = responseModel.investmentReports.cast<InvestmentReport>();
      print("✅ ReportsRepositoryImpl: Successfully converted ${investmentReports.length} investment reports to entities");
      
      return investmentReports;
    } catch (e, stackTrace) {
      print("❌ ReportsRepositoryImpl: Error getting investment reports: $e");
      print("📄 Stack trace: $stackTrace");
      throw Exception('Failed to get investment reports: $e');
    }
  }
}