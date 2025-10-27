import '../entities/tax_report.dart';
import '../entities/balance_sheet.dart';
import '../entities/cash_flow.dart';
import '../entities/portfolio.dart';
import '../entities/payslip.dart';
import '../entities/income_statement.dart';

abstract class ReportsRepository {
  Future<String> generateReport(ReportGenerationRequest request);

  Future<ReportStatus> getReportStatus(String reportId);

  Future<ReportData> getReport(String reportId);

  Future<List<ReportData>> getUserReports();

  Future<String> downloadReport(String reportId);

  Future<void> emailReport(String reportId);

  Future<bool> deleteReport(String reportId);

  Future<List<TaxReport>> getTaxReports();
  Future<List<BalanceSheet>> getAllBalanceSheets();
  Future<CashFlowListResponse> getCashFlow();
  Future<Portfolio> getPortfolioValue();
  Future<PayslipsResponse> getPayslips();
  Future<List<IncomeStatement>> getIncomeStatements();
}

class ReportGenerationRequest {
  final String type;
  final String timePeriod;
  final String format;
  final bool includeDetailedBreakdown;
  final bool emailWhenGenerated;

  ReportGenerationRequest({
    required this.type,
    required this.timePeriod,
    required this.format,
    this.includeDetailedBreakdown = true,
    this.emailWhenGenerated = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'time_period': timePeriod,
      'format': format,
      'include_detailed_breakdown': includeDetailedBreakdown,
      'email_when_generated': emailWhenGenerated,
    };
  }
}

class ReportStatus {
  final String reportId;
  final String status;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;

  ReportStatus({
    required this.reportId,
    required this.status,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
  });

  factory ReportStatus.fromJson(Map<String, dynamic> json) {
    return ReportStatus(
      reportId: json['report_id'],
      status: json['status'],
      errorMessage: json['error_message'],
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }
}

class ReportData {
  final String id;
  final String type;
  final String timePeriod;
  final String format;
  final String status;
  final String? downloadUrl;
  final DateTime createdAt;
  final DateTime? generatedAt;
  final Map<String, dynamic>? metadata;

  ReportData({
    required this.id,
    required this.type,
    required this.timePeriod,
    required this.format,
    required this.status,
    this.downloadUrl,
    required this.createdAt,
    this.generatedAt,
    this.metadata,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      id: json['id'],
      type: json['type'],
      timePeriod: json['time_period'],
      format: json['format'],
      status: json['status'],
      downloadUrl: json['download_url'],
      createdAt: DateTime.parse(json['created_at']),
      generatedAt: json['generated_at'] != null ? DateTime.parse(json['generated_at']) : null,
      metadata: json['metadata'],
    );
  }
}