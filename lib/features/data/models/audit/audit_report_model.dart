import '../../../domain/entities/audit_report.dart';

class AuditReportModel extends AuditReport {
  const AuditReportModel({
    required super.id,
    required super.contractName,
    required super.fileName,
    required super.timestamp,
    required super.status,
    required super.securityAnalysis,
    required super.gasOptimization,
    required super.codeQuality,
    required super.vulnerabilities,
    required super.recommendations,
    required super.overallScore,
  });

  factory AuditReportModel.fromJson(Map<String, dynamic> json) {
    return AuditReportModel(
      id: json['id'] as String,
      contractName: json['contract_name'] as String,
      fileName: json['file_name'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: AuditStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AuditStatus.pending,
      ),
      securityAnalysis: SecurityAnalysisModel.fromJson(json['security_analysis']),
      gasOptimization: GasOptimizationModel.fromJson(json['gas_optimization']),
      codeQuality: CodeQualityModel.fromJson(json['code_quality']),
      vulnerabilities: (json['vulnerabilities'] as List)
          .map((v) => VulnerabilityModel.fromJson(v))
          .toList(),
      recommendations: (json['recommendations'] as List)
          .map((r) => RecommendationModel.fromJson(r))
          .toList(),
      overallScore: (json['overall_score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contract_name': contractName,
      'file_name': fileName,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'security_analysis': (securityAnalysis as SecurityAnalysisModel).toJson(),
      'gas_optimization': (gasOptimization as GasOptimizationModel).toJson(),
      'code_quality': (codeQuality as CodeQualityModel).toJson(),
      'vulnerabilities': vulnerabilities
          .map((v) => (v as VulnerabilityModel).toJson())
          .toList(),
      'recommendations': recommendations
          .map((r) => (r as RecommendationModel).toJson())
          .toList(),
      'overall_score': overallScore,
    };
  }
}

class SecurityAnalysisModel extends SecurityAnalysis {
  const SecurityAnalysisModel({
    required super.criticalIssues,
    required super.highRiskIssues,
    required super.mediumRiskIssues,
    required super.lowRiskIssues,
    required super.securityScore,
    required super.completedChecks,
  });

  factory SecurityAnalysisModel.fromJson(Map<String, dynamic> json) {
    return SecurityAnalysisModel(
      criticalIssues: json['critical_issues'] as int,
      highRiskIssues: json['high_risk_issues'] as int,
      mediumRiskIssues: json['medium_risk_issues'] as int,
      lowRiskIssues: json['low_risk_issues'] as int,
      securityScore: (json['security_score'] as num).toDouble(),
      completedChecks: (json['completed_checks'] as List)
          .map((c) => SecurityCheckModel.fromJson(c))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'critical_issues': criticalIssues,
      'high_risk_issues': highRiskIssues,
      'medium_risk_issues': mediumRiskIssues,
      'low_risk_issues': lowRiskIssues,
      'security_score': securityScore,
      'completed_checks': completedChecks
          .map((c) => (c as SecurityCheckModel).toJson())
          .toList(),
    };
  }
}

class SecurityCheckModel extends SecurityCheck {
  const SecurityCheckModel({
    required super.name,
    required super.description,
    required super.passed,
    super.failureReason,
  });

  factory SecurityCheckModel.fromJson(Map<String, dynamic> json) {
    return SecurityCheckModel(
      name: json['name'] as String,
      description: json['description'] as String,
      passed: json['passed'] as bool,
      failureReason: json['failure_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'passed': passed,
      'failure_reason': failureReason,
    };
  }
}

class GasOptimizationModel extends GasOptimization {
  const GasOptimizationModel({
    required super.estimatedGasSaved,
    required super.optimizationScore,
    required super.suggestions,
  });

  factory GasOptimizationModel.fromJson(Map<String, dynamic> json) {
    return GasOptimizationModel(
      estimatedGasSaved: json['estimated_gas_saved'] as int,
      optimizationScore: (json['optimization_score'] as num).toDouble(),
      suggestions: (json['suggestions'] as List)
          .map((s) => GasOptimizationSuggestionModel.fromJson(s))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estimated_gas_saved': estimatedGasSaved,
      'optimization_score': optimizationScore,
      'suggestions': suggestions
          .map((s) => (s as GasOptimizationSuggestionModel).toJson())
          .toList(),
    };
  }
}

class GasOptimizationSuggestionModel extends GasOptimizationSuggestion {
  const GasOptimizationSuggestionModel({
    required super.function,
    required super.suggestion,
    required super.estimatedSaving,
    required super.priority,
  });

  factory GasOptimizationSuggestionModel.fromJson(Map<String, dynamic> json) {
    return GasOptimizationSuggestionModel(
      function: json['function'] as String,
      suggestion: json['suggestion'] as String,
      estimatedSaving: json['estimated_saving'] as int,
      priority: Priority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => Priority.medium,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'function': function,
      'suggestion': suggestion,
      'estimated_saving': estimatedSaving,
      'priority': priority.name,
    };
  }
}

class CodeQualityModel extends CodeQuality {
  const CodeQualityModel({
    required super.qualityScore,
    required super.linesOfCode,
    required super.complexityScore,
    required super.issues,
  });

  factory CodeQualityModel.fromJson(Map<String, dynamic> json) {
    return CodeQualityModel(
      qualityScore: (json['quality_score'] as num).toDouble(),
      linesOfCode: json['lines_of_code'] as int,
      complexityScore: json['complexity_score'] as int,
      issues: (json['issues'] as List)
          .map((i) => CodeIssueModel.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quality_score': qualityScore,
      'lines_of_code': linesOfCode,
      'complexity_score': complexityScore,
      'issues': issues
          .map((i) => (i as CodeIssueModel).toJson())
          .toList(),
    };
  }
}

class CodeIssueModel extends CodeIssue {
  const CodeIssueModel({
    required super.type,
    required super.description,
    required super.lineNumber,
    required super.severity,
  });

  factory CodeIssueModel.fromJson(Map<String, dynamic> json) {
    return CodeIssueModel(
      type: json['type'] as String,
      description: json['description'] as String,
      lineNumber: json['line_number'] as int,
      severity: Severity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => Severity.info,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'line_number': lineNumber,
      'severity': severity.name,
    };
  }
}

class VulnerabilityModel extends Vulnerability {
  const VulnerabilityModel({
    required super.id,
    required super.title,
    required super.description,
    required super.severity,
    required super.category,
    required super.lineNumbers,
    super.remediation,
  });

  factory VulnerabilityModel.fromJson(Map<String, dynamic> json) {
    return VulnerabilityModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      severity: Severity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => Severity.info,
      ),
      category: json['category'] as String,
      lineNumbers: (json['line_numbers'] as List).cast<int>(),
      remediation: json['remediation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'severity': severity.name,
      'category': category,
      'line_numbers': lineNumbers,
      'remediation': remediation,
    };
  }
}

class RecommendationModel extends Recommendation {
  const RecommendationModel({
    required super.title,
    required super.description,
    required super.priority,
    required super.category,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      title: json['title'] as String,
      description: json['description'] as String,
      priority: Priority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => Priority.medium,
      ),
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'priority': priority.name,
      'category': category,
    };
  }
}
