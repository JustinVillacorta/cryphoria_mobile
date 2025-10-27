import 'dart:io';
import 'package:dio/dio.dart';
import '../models/audit/audit_report_model.dart';
import '../models/tax_report_model.dart';
import '../models/cash_flow_model.dart';
import '../models/balance_sheet_model.dart';
import '../models/portfolio_model.dart';
import '../models/payslip_model.dart';
import '../models/income_statement_model.dart';
import '../../domain/entities/audit_report.dart';

abstract class AuditRemoteDataSource {
  Future<AuditReportModel> uploadContract(File contractFile);
  
  Future<List<TaxReportModel>> getTaxReports();
  Future<List<BalanceSheetModel>> getAllBalanceSheets();
  Future<CashFlowListResponseModel> getCashFlow();
  Future<PortfolioModel> getPortfolioValue();
  Future<PayslipsResponseModel> getPayslips();
  Future<IncomeStatementsResponseModel> getIncomeStatements();
}

class AuditRemoteDataSourceImpl implements AuditRemoteDataSource {
  final Dio dio;

  AuditRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuditReportModel> uploadContract(File contractFile) async {
    
    try {
      
      final formData = FormData.fromMap({
        'contract_file': await MultipartFile.fromFile(
          contractFile.path,
          filename: contractFile.path.split('/').last,
        ),
      });
      
      final response = await dio.post(
        '/api/ai/audit-contract/',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );


      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        
        if (responseData['success'] == true && responseData['audit'] != null) {
          final auditData = responseData['audit'] as Map<String, dynamic>;
          return _parseAuditResponse(auditData);
        } else {
          throw Exception('Unexpected response format from audit endpoint');
        }
      } else {
        throw Exception('Failed to upload contract: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  AuditReportModel _parseAuditResponse(Map<String, dynamic> auditData) {
    
    final vulnerabilities = <VulnerabilityModel>[];
    
    List<dynamic> vulnList = [];
    if (auditData['vulnerabilities'] != null) {
      vulnList = auditData['vulnerabilities'] as List<dynamic>;
    } else if (auditData['ai_vulnerabilities'] != null) {
      vulnList = auditData['ai_vulnerabilities'] as List<dynamic>;
    }
    
    if (vulnList.isNotEmpty) {
      for (int i = 0; i < vulnList.length; i++) {
        final vuln = vulnList[i] as Map<String, dynamic>;
        
        Severity severity;
        final severityString = (vuln['severity'] as String).toUpperCase();
        switch (severityString) {
          case 'HIGH':
            severity = Severity.high;
            break;
          case 'MEDIUM':
            severity = Severity.medium;
            break;
          case 'LOW':
            severity = Severity.low;
            break;
          case 'CRITICAL':
            severity = Severity.critical;
            break;
          default:
            severity = Severity.info;
        }
        
        final vulnerability = VulnerabilityModel(
          id: 'vuln_${auditData['audit_id']}_$i',
          title: vuln['title'] as String? ?? 'Unknown Vulnerability',
          description: vuln['description'] as String? ?? 'No description available',
          severity: severity,
          category: vuln['category'] as String? ?? vuln['cwe_id'] as String? ?? 'Unknown',
          lineNumbers: vuln['line_number'] != null ? [vuln['line_number'] as int] : [],
          remediation: vuln['recommendation'] as String?,
        );
        
        vulnerabilities.add(vulnerability);
      }
    } else {
    }
    

    final criticalIssues = vulnerabilities.where((v) => v.severity == Severity.critical).length;
    final highRiskIssues = vulnerabilities.where((v) => v.severity == Severity.high).length;
    final mediumRiskIssues = vulnerabilities.where((v) => v.severity == Severity.medium).length;
    final lowRiskIssues = vulnerabilities.where((v) => v.severity == Severity.low).length;
    
    final securityScore = _calculateSecurityScore(criticalIssues, highRiskIssues, mediumRiskIssues, lowRiskIssues);

    final securityAnalysis = SecurityAnalysisModel(
      criticalIssues: criticalIssues,
      highRiskIssues: highRiskIssues,
      mediumRiskIssues: mediumRiskIssues,
      lowRiskIssues: lowRiskIssues,
      securityScore: securityScore,
      completedChecks: [],
    );

    final recommendations = <RecommendationModel>[];
    
    if (auditData['recommendations'] != null) {
      final recString = auditData['recommendations'] as String;
      if (recString.isNotEmpty) {
        final recLines = recString.split('\n').where((line) => line.trim().isNotEmpty).toList();
        for (int i = 0; i < recLines.length; i++) {
          final line = recLines[i].trim();
          final priority = _parseRecommendationPriority(line);
          final category = _parseRecommendationCategory(line);
          
          recommendations.add(RecommendationModel(
            title: 'Recommendation ${i + 1}',
            description: line,
            priority: priority,
            category: category,
          ));
        }
      }
    }
    
    if (auditData['ai_recommendations'] != null) {
      final aiRecs = auditData['ai_recommendations'] as List<dynamic>;
      for (int i = 0; i < aiRecs.length; i++) {
        final rec = aiRecs[i] as String;
        recommendations.add(RecommendationModel(
          title: 'AI Recommendation ${i + 1}',
          description: rec,
          priority: Priority.medium,
          category: 'AI Analysis',
        ));
      }
    }

    final gasScore = _parseGasOptimizationScore(auditData);
    final gasSuggestions = _parseGasOptimizationSuggestions(auditData);
    
    final gasOptimization = GasOptimizationModel(
      optimizationScore: gasScore,
      suggestions: gasSuggestions,
    );

    final linesOfCode = auditData['source_code']?.toString().split('\n').length ?? 0;
    final codeQualityScore = _calculateCodeQualityScore(linesOfCode, vulnerabilities.length);
    final complexityScore = _calculateComplexityScore(linesOfCode);
    
    final codeQuality = CodeQualityModel(
      qualityScore: codeQualityScore,
      linesOfCode: linesOfCode,
      complexityScore: complexityScore,
      issues: [],
    );

    return AuditReportModel(
      id: auditData['audit_id'] as String? ?? auditData['_id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      contractName: auditData['contract_name'] as String? ?? 'Unknown Contract',
      fileName: auditData['filename'] as String? ?? 'contract.sol',
      timestamp: DateTime.parse(auditData['created_at'] as String? ?? DateTime.now().toIso8601String()),
      status: AuditStatus.completed,
      securityAnalysis: securityAnalysis,
      gasOptimization: gasOptimization,
      codeQuality: codeQuality,
      vulnerabilities: vulnerabilities,
      recommendations: recommendations,
      overallScore: _calculateOverallScore(securityScore, gasOptimization.optimizationScore, codeQuality.qualityScore),
    );
    
    
  }

  double _calculateSecurityScore(int critical, int high, int medium, int low) {
    final totalIssues = critical + high + medium + low;
    if (totalIssues == 0) return 100.0;
    
    final weightedScore = (critical * 0) + (high * 20) + (medium * 60) + (low * 80);
    return (weightedScore / totalIssues).clamp(0.0, 100.0);
  }

  double _calculateOverallScore(double security, double gas, double quality) {
    return (security * 0.5 + gas * 0.3 + quality * 0.2).clamp(0.0, 100.0);
  }

  double _calculateCodeQualityScore(int linesOfCode, int vulnerabilityCount) {
    double score = 100.0;
    
    score -= vulnerabilityCount * 5.0;
    
    if (linesOfCode > 500) {
      score -= 10.0;
    } else if (linesOfCode > 1000) {
      score -= 20.0;
    }
    
    return score.clamp(0.0, 100.0);
  }

  int _calculateComplexityScore(int linesOfCode) {
    if (linesOfCode < 100) return 1;
    if (linesOfCode < 300) return 2;
    if (linesOfCode < 500) return 3;
    if (linesOfCode < 1000) return 4;
    return 5;
  }

  Priority _parseRecommendationPriority(String recommendation) {
    final lowerRec = recommendation.toLowerCase();
    if (lowerRec.contains('high priority') || lowerRec.contains('critical')) {
      return Priority.high;
    } else if (lowerRec.contains('medium priority') || lowerRec.contains('important')) {
      return Priority.medium;
    } else if (lowerRec.contains('low priority') || lowerRec.contains('minor')) {
      return Priority.low;
    }
    return Priority.medium;
  }

  String _parseRecommendationCategory(String recommendation) {
    final lowerRec = recommendation.toLowerCase();
    if (lowerRec.contains('security') || lowerRec.contains('reentrancy') || lowerRec.contains('access control')) {
      return 'Security';
    } else if (lowerRec.contains('gas') || lowerRec.contains('optimization')) {
      return 'Gas Optimization';
    } else if (lowerRec.contains('testing') || lowerRec.contains('verification')) {
      return 'Testing';
    } else if (lowerRec.contains('ai analysis')) {
      return 'AI Analysis';
    }
    return 'General';
  }

  double _parseGasOptimizationScore(Map<String, dynamic> auditData) {
    if (auditData['gas_optimization'] != null) {
      final gasOptString = auditData['gas_optimization'] as String;
      
      if (gasOptString.toLowerCase().contains('error')) {
        return 30.0;
      }
      
      final scoreMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(gasOptString);
      if (scoreMatch != null) {
        return double.tryParse(scoreMatch.group(1)!) ?? 50.0;
      }
    }
    
    return 50.0;
  }

  List<GasOptimizationSuggestionModel> _parseGasOptimizationSuggestions(Map<String, dynamic> auditData) {
    final suggestions = <GasOptimizationSuggestionModel>[];
    
    if (auditData['gas_optimization'] != null) {
      final gasOptString = auditData['gas_optimization'] as String;
      
      if (gasOptString.toLowerCase().contains('error')) {
        suggestions.add(GasOptimizationSuggestionModel(
          function: 'Gas Analysis',
          suggestion: 'Gas optimization analysis failed: $gasOptString. Manual review recommended.',
          priority: Priority.high,
        ));
      } else if (gasOptString.isNotEmpty && !gasOptString.toLowerCase().contains('error')) {
        suggestions.add(GasOptimizationSuggestionModel(
          function: 'Gas Optimization',
          suggestion: gasOptString,
          priority: Priority.medium,
        ));
      }
    }
    
    List<dynamic> vulnList = [];
    if (auditData['vulnerabilities'] != null) {
      vulnList = auditData['vulnerabilities'] as List<dynamic>;
    } else if (auditData['ai_vulnerabilities'] != null) {
      vulnList = auditData['ai_vulnerabilities'] as List<dynamic>;
    }
    
    if (vulnList.isNotEmpty) {
      final hasArithmeticIssues = vulnList.any((vuln) => 
        (vuln['category'] as String?)?.toLowerCase().contains('arithmetic') == true ||
        (vuln['cwe_id'] as String?)?.contains('190') == true);
      
      if (hasArithmeticIssues) {
        suggestions.add(GasOptimizationSuggestionModel(
          function: 'Arithmetic Operations',
          suggestion: 'Consider using SafeMath library or Solidity 0.8+ for overflow protection to reduce gas costs.',
          priority: Priority.high,
        ));
      }
      
      final gasOptimizationVulns = vulnList.where((vuln) => 
        (vuln['title'] as String?)?.toLowerCase().contains('gas') == true).toList();
      
      for (final vuln in gasOptimizationVulns) {
        suggestions.add(GasOptimizationSuggestionModel(
          function: 'Gas Optimization',
          suggestion: vuln['recommendation'] as String? ?? vuln['description'] as String? ?? 'Review gas usage patterns',
          priority: Priority.medium,
        ));
      }
    }
    
    return suggestions;
  }


  @override
  Future<List<TaxReportModel>> getTaxReports() async {
    try {
      
      final response = await dio.get('/api/financial/tax-report/list');


      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
          
          if (responseData.containsKey('success') && responseData.containsKey('tax_reports')) {
            final bool success = responseData['success'] as bool? ?? false;
            if (!success) {
              throw Exception('API returned success: false');
            }
            
            final dynamic taxReportsData = responseData['tax_reports'];
            if (taxReportsData is List) {
              final List<dynamic> reports = taxReportsData;
              return reports.map((report) => TaxReportModel.fromJson(report as Map<String, dynamic>)).toList();
            } else if (taxReportsData is Map<String, dynamic>) {
              return [TaxReportModel.fromJson(taxReportsData)];
            } else {
              throw Exception('Unexpected tax_reports format: ${taxReportsData.runtimeType}');
            }
          } else {
            if (responseData is List) {
              final List<dynamic> reports = responseData as List<dynamic>;
              return reports.map((report) => TaxReportModel.fromJson(report as Map<String, dynamic>)).toList();
            } else {
              return [TaxReportModel.fromJson(responseData)];
            }
          }
        } else if (response.data is List) {
          final List<dynamic> reports = response.data as List<dynamic>;
          return reports.map((report) => TaxReportModel.fromJson(report as Map<String, dynamic>)).toList();
        } else {
          throw Exception('Unexpected response format: ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to get tax reports: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<List<BalanceSheetModel>> getAllBalanceSheets() async {
    try {
      
      final response = await dio.get('/api/financial/balance-sheet/list/');


      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final List<dynamic> balanceSheets = responseData['balance_sheets'] as List<dynamic>;
        return balanceSheets.map((sheet) => BalanceSheetModel.fromJson(sheet as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to get balance sheets: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<CashFlowListResponseModel> getCashFlow() async {
    try {
      
      final response = await dio.get('/api/financial/cash-flow/list/');


      if (response.statusCode == 200) {
        return CashFlowListResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get cash flow: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<PortfolioModel> getPortfolioValue() async {
    try {
      
      final response = await dio.get('/api/portfolio/value/', queryParameters: {
        'currency': 'USD',
      });


      if (response.statusCode == 200) {
        final responseData = Map<String, dynamic>.from(response.data as Map);
        
        if (responseData['success'] == true) {
          return PortfolioModel.fromJson(responseData);
        } else {
          throw Exception('Failed to get portfolio value: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to get portfolio value: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<PayslipsResponseModel> getPayslips() async {
    try {
      
      final response = await dio.get('/api/payslips/list/');


      if (response.statusCode == 200) {
        return PayslipsResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get payslips: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<IncomeStatementsResponseModel> getIncomeStatements() async {
    try {
      
      final response = await dio.get('/api/financial/income-statement/list/');


      if (response.statusCode == 200) {
        return IncomeStatementsResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get income statements: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}