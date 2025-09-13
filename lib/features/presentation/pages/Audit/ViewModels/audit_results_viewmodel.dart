import 'package:flutter/material.dart';
import '../../../../domain/entities/audit_report.dart';
import '../../../../domain/usecases/Audit/get_audit_report_usecase.dart';

class AuditResultsViewModel extends ChangeNotifier {
  final GetAuditReportUseCase getAuditReportUseCase;

  AuditResultsViewModel({
    required this.getAuditReportUseCase,
  });

  // State
  bool _isLoading = false;
  String? _error;
  AuditReport? _auditReport;
  int _selectedTabIndex = 0;
  List<Vulnerability> _filteredVulnerabilities = [];
  Severity? _selectedSeverityFilter;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  AuditReport? get auditReport => _auditReport;
  int get selectedTabIndex => _selectedTabIndex;
  List<Vulnerability> get filteredVulnerabilities => _filteredVulnerabilities;
  Severity? get selectedSeverityFilter => _selectedSeverityFilter;
  
  // Computed properties
  bool get hasReport => _auditReport != null;
  
  // Security metrics
  int get totalVulnerabilities => _auditReport?.vulnerabilities.length ?? 0;
  int get criticalCount => _auditReport?.securityAnalysis.criticalIssues ?? 0;
  int get highCount => _auditReport?.securityAnalysis.highRiskIssues ?? 0;
  int get mediumCount => _auditReport?.securityAnalysis.mediumRiskIssues ?? 0;
  int get lowCount => _auditReport?.securityAnalysis.lowRiskIssues ?? 0;
  
  // Risk assessment
  Color get riskColor {
    if (_auditReport == null) return Colors.grey;
    
    final score = _auditReport!.overallScore;
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
  
  String get riskLevel {
    if (_auditReport == null) return 'Unknown';
    
    final score = _auditReport!.overallScore;
    if (score >= 80) return 'Low Risk';
    if (score >= 60) return 'Medium Risk';
    return 'High Risk';
  }

  // Load audit report
  Future<void> loadAuditReport(String auditId) async {
    _setLoading(true);
    _clearError();

    try {
      _auditReport = await getAuditReportUseCase.execute(auditId);
      _filteredVulnerabilities = List.from(_auditReport!.vulnerabilities);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load audit report: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Tab management
  void setSelectedTab(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  // Vulnerability filtering
  void filterBySeverity(Severity? severity) {
    _selectedSeverityFilter = severity;
    
    if (severity == null) {
      _filteredVulnerabilities = List.from(_auditReport?.vulnerabilities ?? []);
    } else {
      _filteredVulnerabilities = _auditReport?.vulnerabilities
          .where((v) => v.severity == severity)
          .toList() ?? [];
    }
    
    notifyListeners();
  }

  void clearFilter() {
    filterBySeverity(null);
  }

  // Get vulnerabilities by severity
  List<Vulnerability> getVulnerabilitiesBySeverity(Severity severity) {
    return _auditReport?.vulnerabilities
        .where((v) => v.severity == severity)
        .toList() ?? [];
  }

  // Get recommendations by priority
  List<Recommendation> getRecommendationsByPriority(Priority priority) {
    return _auditReport?.recommendations
        .where((r) => r.priority == priority)
        .toList() ?? [];
  }

  // Overall assessment calculations
  String getAssessmentTitle() {
    if (_auditReport == null) return 'Assessment Unavailable';
    
    final score = _auditReport!.overallScore;
    if (score >= 90) return 'Excellent Security';
    if (score >= 80) return 'Good Security';
    if (score >= 70) return 'Fair Security';
    if (score >= 60) return 'Poor Security';
    return 'Critical Issues';
  }

  String getAssessmentDescription() {
    if (_auditReport == null) return 'No assessment data available';
    
    final score = _auditReport!.overallScore;
    if (score >= 80) {
      return 'Your smart contract demonstrates strong security practices with minimal risks.';
    } else if (score >= 60) {
      return 'Your smart contract has some security concerns that should be addressed.';
    } else {
      return 'Your smart contract has significant security vulnerabilities that require immediate attention.';
    }
  }

  List<String> getTopRecommendations() {
    if (_auditReport == null) return [];
    
    return _auditReport!.recommendations
        .where((r) => r.priority == Priority.high)
        .take(3)
        .map((r) => r.title)
        .toList();
  }

  // Reset state
  void reset() {
    _auditReport = null;
    _selectedTabIndex = 0;
    _filteredVulnerabilities = [];
    _selectedSeverityFilter = null;
    _clearError();
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
