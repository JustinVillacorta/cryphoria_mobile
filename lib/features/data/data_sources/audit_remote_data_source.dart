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
  
  // Financial Reports
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
    print("🌐 AuditRemoteDataSource.uploadContract called");
    print("📁 File: ${contractFile.path}");
    
    try {
      print("📤 Making POST request to /api/ai/audit-contract/");
      
      // Create FormData with file upload
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

            print("📥 Upload contract response:");
            print("📊 Status code: ${response.statusCode}");
            print("📄 Response data: ${response.data}");
            
            // Debug: Print the full response structure
            if (response.data is Map<String, dynamic>) {
              final responseData = response.data as Map<String, dynamic>;
              print("🔍 Response structure:");
              print("  - success: ${responseData['success']}");
              print("  - audit: ${responseData['audit']}");
              if (responseData['audit'] != null) {
                final auditData = responseData['audit'] as Map<String, dynamic>;
                print("  - audit.vulnerabilities: ${auditData['vulnerabilities']}");
                print("  - audit.vulnerabilities_found: ${auditData['vulnerabilities_found']}");
                print("  - audit.ai_vulnerabilities: ${auditData['ai_vulnerabilities']}");
              }
            }

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        
        // Check if the response has the expected format with audit data
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
      print("❌ DioException in uploadContract: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  AuditReportModel _parseAuditResponse(Map<String, dynamic> auditData) {
    print("🔍 Parsing audit response data:");
    print("📊 Vulnerabilities count: ${auditData['vulnerabilities']?.length ?? 0}");
    print("⛽ Gas optimization: ${auditData['gas_optimization']}");
    print("📝 Recommendations: ${auditData['recommendations']?.toString().substring(0, 100)}...");
    
    // Debug: Print all available fields in auditData
    print("🔍 All audit data fields:");
    auditData.forEach((key, value) {
      print("  - $key: ${value.runtimeType} = $value");
    });
    
    // Debug: Print the entire vulnerabilities array
    if (auditData['vulnerabilities'] != null) {
      print("🔍 Raw vulnerabilities array:");
      final vulnList = auditData['vulnerabilities'] as List<dynamic>;
      for (int i = 0; i < vulnList.length; i++) {
        print("  Vulnerability $i: ${vulnList[i]}");
      }
    } else {
      print("🔍 No vulnerabilities field found in audit data");
    }
    
    // Parse vulnerabilities from the API response
    final vulnerabilities = <VulnerabilityModel>[];
    
    // Check both 'vulnerabilities' and 'ai_vulnerabilities' fields
    List<dynamic> vulnList = [];
    if (auditData['vulnerabilities'] != null) {
      vulnList = auditData['vulnerabilities'] as List<dynamic>;
      print("🔍 Found ${vulnList.length} vulnerabilities in 'vulnerabilities' field");
    } else if (auditData['ai_vulnerabilities'] != null) {
      vulnList = auditData['ai_vulnerabilities'] as List<dynamic>;
      print("🔍 Found ${vulnList.length} vulnerabilities in 'ai_vulnerabilities' field");
    }
    
    if (vulnList.isNotEmpty) {
      print("🔍 Processing ${vulnList.length} vulnerabilities from API");
      for (int i = 0; i < vulnList.length; i++) {
        final vuln = vulnList[i] as Map<String, dynamic>;
        print("🔍 Processing vulnerability $i: ${vuln['title']}");
        
        // Map severity from API format to enum
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
        print("✅ Added vulnerability: ${vulnerability.title} (${severity.name})");
      }
    } else {
      print("🔍 No vulnerabilities found in either 'vulnerabilities' or 'ai_vulnerabilities' fields");
    }
    
    print("🔍 Final vulnerabilities count after parsing: ${vulnerabilities.length}");

    // Calculate security metrics from vulnerabilities
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

    // Parse recommendations from audit report
    final recommendations = <RecommendationModel>[];
    if (auditData['recommendations'] != null) {
      final recString = auditData['recommendations'] as String;
      if (recString.isNotEmpty) {
        // Split recommendations by newlines and create recommendation objects
        final recLines = recString.split('\n').where((line) => line.trim().isNotEmpty).toList();
        for (int i = 0; i < recLines.length; i++) {
        recommendations.add(RecommendationModel(
            title: 'Recommendation ${i + 1}',
            description: recLines[i].trim(),
            priority: Priority.high,
            category: 'Security',
          ));
        }
      }
    }

    // Parse gas optimization from API response
    final gasScore = _parseGasOptimizationScore(auditData);
    final gasSuggestions = _parseGasOptimizationSuggestions(auditData);
    print("⛽ Gas optimization score: $gasScore");
    print("⛽ Gas optimization suggestions count: ${gasSuggestions.length}");
    
    final gasOptimization = GasOptimizationModel(
      optimizationScore: gasScore,
      suggestions: gasSuggestions,
    );

    // Create code quality
    final codeQuality = CodeQualityModel(
      qualityScore: 70.0,
      linesOfCode: auditData['source_code']?.toString().split('\n').length ?? 0,
      complexityScore: 5,
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
    
    print("✅ Final audit report created:");
    print("📊 Vulnerabilities: ${vulnerabilities.length}");
    print("⛽ Gas suggestions: ${gasOptimization.suggestions.length}");
    print("📝 Recommendations: ${recommendations.length}");
    print("🎯 Overall score: ${_calculateOverallScore(securityScore, gasOptimization.optimizationScore, codeQuality.qualityScore)}");
    
    // Debug: Print first few vulnerabilities in detail
    if (vulnerabilities.isNotEmpty) {
      print("🔍 First vulnerability details:");
      final firstVuln = vulnerabilities.first;
      print("  ID: ${firstVuln.id}");
      print("  Title: ${firstVuln.title}");
      print("  Description: ${firstVuln.description}");
      print("  Severity: ${firstVuln.severity.name}");
      print("  Category: ${firstVuln.category}");
      print("  Line Numbers: ${firstVuln.lineNumbers}");
      print("  Remediation: ${firstVuln.remediation}");
    }
    
    // Debug: Print first few gas optimization suggestions
    if (gasOptimization.suggestions.isNotEmpty) {
      print("⛽ First gas optimization suggestion:");
      final firstSuggestion = gasOptimization.suggestions.first;
      print("  Function: ${firstSuggestion.function}");
      print("  Suggestion: ${firstSuggestion.suggestion}");
      print("  Priority: ${firstSuggestion.priority.name}");
    }
  }

  double _calculateSecurityScore(int critical, int high, int medium, int low) {
    // Calculate security score based on vulnerability counts
    final totalIssues = critical + high + medium + low;
    if (totalIssues == 0) return 100.0;
    
    final weightedScore = (critical * 0) + (high * 20) + (medium * 60) + (low * 80);
    return (weightedScore / totalIssues).clamp(0.0, 100.0);
  }

  double _calculateOverallScore(double security, double gas, double quality) {
    return (security * 0.5 + gas * 0.3 + quality * 0.2).clamp(0.0, 100.0);
  }

  double _parseGasOptimizationScore(Map<String, dynamic> auditData) {
    // Try to extract gas optimization score from the API response
    if (auditData['gas_optimization'] != null) {
      final gasOptString = auditData['gas_optimization'] as String;
      
      // If it's an error message, return a low score
      if (gasOptString.toLowerCase().contains('error')) {
        return 30.0; // Low score for analysis errors
      }
      
      // Try to parse a numeric score if present
      final scoreMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(gasOptString);
      if (scoreMatch != null) {
        return double.tryParse(scoreMatch.group(1)!) ?? 50.0;
      }
    }
    
    // Default score if no gas optimization data available
    return 50.0;
  }

  List<GasOptimizationSuggestionModel> _parseGasOptimizationSuggestions(Map<String, dynamic> auditData) {
    final suggestions = <GasOptimizationSuggestionModel>[];
    
    // Check if there are gas optimization suggestions in the API response
    if (auditData['gas_optimization'] != null) {
      final gasOptString = auditData['gas_optimization'] as String;
      
      // If it's an error message, create a suggestion about the error
      if (gasOptString.toLowerCase().contains('error')) {
        suggestions.add(GasOptimizationSuggestionModel(
          function: 'Gas Analysis',
          suggestion: 'Gas optimization analysis failed: $gasOptString. Manual review recommended.',
          priority: Priority.high,
        ));
      } else if (gasOptString.isNotEmpty && !gasOptString.toLowerCase().contains('error')) {
        // If there's actual gas optimization data, parse it
        suggestions.add(GasOptimizationSuggestionModel(
          function: 'Gas Optimization',
          suggestion: gasOptString,
          priority: Priority.medium,
        ));
      }
    }
    
    // Add some general gas optimization suggestions based on vulnerabilities
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
      
      // Add gas optimization suggestions based on AI vulnerabilities
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
      print("📤 Getting tax reports from /api/financial/tax-report/list");
      
      final response = await dio.get('/api/financial/tax-report/list');

      print("📥 Tax reports response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200) {
        // Check if response has the wrapper structure with success and tax_reports
        if (response.data is Map<String, dynamic>) {
          final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
          
          // Check if it's the expected wrapper format
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
              // Single report object - wrap it in a list
              return [TaxReportModel.fromJson(taxReportsData)];
            } else {
              throw Exception('Unexpected tax_reports format: ${taxReportsData.runtimeType}');
            }
          } else {
            // Fallback: handle direct array or single object (legacy format)
            if (responseData is List) {
              final List<dynamic> reports = responseData as List<dynamic>;
              return reports.map((report) => TaxReportModel.fromJson(report as Map<String, dynamic>)).toList();
            } else {
              // Single report object - wrap it in a list
              return [TaxReportModel.fromJson(responseData)];
            }
          }
        } else if (response.data is List) {
          // Direct array response (legacy format)
          final List<dynamic> reports = response.data as List<dynamic>;
          return reports.map((report) => TaxReportModel.fromJson(report as Map<String, dynamic>)).toList();
        } else {
          throw Exception('Unexpected response format: ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to get tax reports: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Error getting tax reports: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<List<BalanceSheetModel>> getAllBalanceSheets() async {
    try {
      print("📤 Getting all balance sheets from /api/financial/balance-sheet/list/");
      
      final response = await dio.get('/api/financial/balance-sheet/list/');

      print("📥 All balance sheets response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final List<dynamic> balanceSheets = responseData['balance_sheets'] as List<dynamic>;
        return balanceSheets.map((sheet) => BalanceSheetModel.fromJson(sheet as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to get balance sheets: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Error getting all balance sheets: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<CashFlowListResponseModel> getCashFlow() async {
    try {
      print("📤 Getting cash flow from /api/financial/cash-flow/list/");
      
      final response = await dio.get('/api/financial/cash-flow/list/');

      print("📥 Cash flow response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200) {
        return CashFlowListResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get cash flow: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Error getting cash flow: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<PortfolioModel> getPortfolioValue() async {
    try {
      print("📤 Getting portfolio value from /api/portfolio/value/");
      
      final response = await dio.get('/api/portfolio/value/', queryParameters: {
        'currency': 'USD',
      });

      print("📥 Portfolio value response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200) {
        // Safely cast the response data
        final responseData = Map<String, dynamic>.from(response.data as Map);
        
        // Handle the actual API response structure
        if (responseData['success'] == true) {
          return PortfolioModel.fromJson(responseData);
        } else {
          throw Exception('Failed to get portfolio value: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to get portfolio value: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Error getting portfolio value: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<PayslipsResponseModel> getPayslips() async {
    try {
      print("📤 Getting payslips from /api/payslips/list/");
      
      final response = await dio.get('/api/payslips/list/');

      print("📥 Payslips response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200) {
        return PayslipsResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get payslips: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Error getting payslips: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<IncomeStatementsResponseModel> getIncomeStatements() async {
    try {
      print("📤 Getting income statements from /api/financial/income-statement/list/");
      
      final response = await dio.get('/api/financial/income-statement/list/');

      print("📥 Income statements response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200) {
        return IncomeStatementsResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get income statements: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Error getting income statements: $e");
      throw Exception('Network error: ${e.message}');
    }
  }
}