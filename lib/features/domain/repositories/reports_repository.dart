import '../entities/tax_report.dart';
import '../entities/balance_sheet.dart';
import '../entities/cash_flow.dart';
import '../entities/portfolio.dart';
import '../entities/payslip.dart';

abstract class ReportsRepository {
  /// Generate a report with specified parameters
  Future<String> generateReport(ReportGenerationRequest request);

  /// Get report generation status
  Future<ReportStatus> getReportStatus(String reportId);

  /// Get generated report data
  Future<ReportData> getReport(String reportId);

  /// Get list of user's generated reports
  Future<List<ReportData>> getUserReports();

  /// Download report file
  Future<String> downloadReport(String reportId);

  /// Email report to user
  Future<void> emailReport(String reportId);

  /// Delete a report
  Future<bool> deleteReport(String reportId);

  /// Financial Reports
  Future<TaxReport> getTaxReports();
  Future<BalanceSheet> getBalanceSheet();
  Future<CashFlow> getCashFlow();
  Future<Portfolio> getPortfolioValue();
  Future<PayslipsResponse> getPayslips();
}

// Request model for report generation
class ReportGenerationRequest {
  final String type; // 'Payroll', 'Tax', 'Summary'
  final String timePeriod; // 'Current Period', 'Previous Period', etc.
  final String format; // 'PDF', 'EXCEL', 'CSV'
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

// Status of report generation
class ReportStatus {
  final String reportId;
  final String status; // 'pending', 'processing', 'completed', 'failed'
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

// Report data model
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