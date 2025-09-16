class AuditReport {
  final String id;
  final String contractName;
  final String fileName;
  final DateTime timestamp;
  final AuditStatus status;
  final SecurityAnalysis securityAnalysis;
  final GasOptimization gasOptimization;
  final CodeQuality codeQuality;
  final List<Vulnerability> vulnerabilities;
  final List<Recommendation> recommendations;
  final double overallScore;

  const AuditReport({
    required this.id,
    required this.contractName,
    required this.fileName,
    required this.timestamp,
    required this.status,
    required this.securityAnalysis,
    required this.gasOptimization,
    required this.codeQuality,
    required this.vulnerabilities,
    required this.recommendations,
    required this.overallScore,
  });
}

class SecurityAnalysis {
  final int criticalIssues;
  final int highRiskIssues;
  final int mediumRiskIssues;
  final int lowRiskIssues;
  final double securityScore;
  final List<SecurityCheck> completedChecks;

  const SecurityAnalysis({
    required this.criticalIssues,
    required this.highRiskIssues,
    required this.mediumRiskIssues,
    required this.lowRiskIssues,
    required this.securityScore,
    required this.completedChecks,
  });
}

class SecurityCheck {
  final String name;
  final String description;
  final bool passed;
  final String? failureReason;

  const SecurityCheck({
    required this.name,
    required this.description,
    required this.passed,
    this.failureReason,
  });
}

class GasOptimization {
  final double optimizationScore;
  final List<GasOptimizationSuggestion> suggestions;

  const GasOptimization({
    required this.optimizationScore,
    required this.suggestions,
  });
}

class GasOptimizationSuggestion {
  final String function;
  final String suggestion;
  final Priority priority;

  const GasOptimizationSuggestion({
    required this.function,
    required this.suggestion,
    required this.priority,
  });
}

class CodeQuality {
  final double qualityScore;
  final int linesOfCode;
  final int complexityScore;
  final List<CodeIssue> issues;

  const CodeQuality({
    required this.qualityScore,
    required this.linesOfCode,
    required this.complexityScore,
    required this.issues,
  });
}

class CodeIssue {
  final String type;
  final String description;
  final int lineNumber;
  final Severity severity;

  const CodeIssue({
    required this.type,
    required this.description,
    required this.lineNumber,
    required this.severity,
  });
}

class Vulnerability {
  final String id;
  final String title;
  final String description;
  final Severity severity;
  final String category;
  final List<int> lineNumbers;
  final String? remediation;

  const Vulnerability({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
    required this.lineNumbers,
    this.remediation,
  });
}

class Recommendation {
  final String title;
  final String description;
  final Priority priority;
  final String category;

  const Recommendation({
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
  });
}

enum AuditStatus {
  pending,
  inProgress,
  completed,
  failed,
}

enum Severity {
  critical,
  high,
  medium,
  low,
  info,
}

enum Priority {
  high,
  medium,
  low,
}
