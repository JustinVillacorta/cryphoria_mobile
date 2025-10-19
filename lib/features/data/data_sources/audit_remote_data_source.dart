import 'package:dio/dio.dart';
import '../models/audit/audit_report_model.dart';
import '../models/audit/smart_contract_model.dart';
import '../models/tax_report_model.dart';
import '../models/balance_sheet_model.dart';
import '../models/cash_flow_model.dart';
import '../models/portfolio_model.dart';
import '../models/payslip_model.dart';
import '../models/income_statement_model.dart';
import '../models/investment_report_model.dart';
import '../../domain/entities/audit_report.dart';
import '../../domain/entities/smart_contract.dart';

abstract class AuditRemoteDataSource {
  Future<String> submitAuditRequest(AuditRequestModel request);
  Future<AuditStatus> getAuditStatus(String auditId);
  Future<AuditReportModel> getAuditReport(String auditId);
  Future<List<AuditReportModel>> getUserAuditReports();
  Future<bool> cancelAudit(String auditId);
  Future<SmartContractModel> uploadContract(String name, String fileName, String sourceCode);
  Future<SmartContractModel> getContract(String contractId);
  Future<bool> deleteContract(String contractId);
  Future<List<ContractType>> getSupportedContractTypes();
  Future<bool> validateContractCode(String sourceCode);
  
  // Financial Reports
  Future<List<TaxReportModel>> getTaxReports();
  Future<BalanceSheetModel> getBalanceSheet();
  Future<List<BalanceSheetModel>> getAllBalanceSheets();
  Future<CashFlowModel> getCashFlow();
  Future<PortfolioModel> getPortfolioValue();
  Future<PayslipsResponseModel> getPayslips();
  Future<IncomeStatementsResponseModel> getIncomeStatements();
  Future<InvestmentReportsResponseModel> getInvestmentReports();
}

class AuditRemoteDataSourceImpl implements AuditRemoteDataSource {
  final Dio dio;

  AuditRemoteDataSourceImpl({required this.dio});

  @override
  Future<String> submitAuditRequest(AuditRequestModel request) async {
    print("🌐 AuditRemoteDataSource.submitAuditRequest called");
    print("📋 Audit request: ${request.toJson()}");
    
    try {
      print("📤 Making POST request to /api/ai/audit-contract/");
      
      final response = await dio.post(
        '/api/ai/audit-contract/',
        data: {
          'contract_code': request.sourceCode,
          'contract_name': request.contractName,
          'contract_address': '', // Optional
          'upload_method': 'text',
        },
      );

      print("📥 Submit audit response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200) {
        final responseData = response.data;
        // Extract audit_id from nested audit object
        final auditData = responseData['audit'] as Map<String, dynamic>?;
        return auditData?['audit_id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString();
      } else {
        throw Exception('Failed to submit audit request: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ DioException in submitAuditRequest: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<AuditStatus> getAuditStatus(String auditId) async {
    try {
      print("📤 Getting audit status for ID: $auditId");
      
      final response = await dio.get('/api/ai/audits/details/', queryParameters: {
        'audit_id': auditId,
      });

      print("📥 Audit status response: ${response.data}");

      if (response.statusCode == 200) {
        // Handle nested response format: {"success": true, "audit": {"status": "COMPLETED", ...}}
        final responseData = response.data as Map<String, dynamic>;
        
        if (responseData['success'] == true && responseData['audit'] != null) {
          final auditData = responseData['audit'] as Map<String, dynamic>;
          final statusString = auditData['status'] as String? ?? 'COMPLETED';
          
          print("🔍 Extracted status: $statusString");
          
          // Convert backend status format to our enum
          switch (statusString.toUpperCase()) {
            case 'COMPLETED':
              return AuditStatus.completed;
            case 'PENDING':
              return AuditStatus.pending;
            case 'PROCESSING':
            case 'IN_PROGRESS':
              return AuditStatus.inProgress;
            case 'FAILED':
              return AuditStatus.failed;
            default:
              print("⚠️ Unknown status '$statusString', defaulting to completed");
              return AuditStatus.completed;
          }
        } else {
          print("⚠️ Invalid response format, defaulting to completed");
          return AuditStatus.completed;
        }
      } else {
        throw Exception('Failed to get audit status: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Error getting audit status: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<AuditReportModel> getAuditReport(String auditId) async {
    try {
      print("📤 Getting audit report for ID: $auditId");
      
      final response = await dio.get('/api/ai/audits/details/', queryParameters: {
        'audit_id': auditId,
      });

      print("📥 Audit report response status: ${response.statusCode}");
      print("📥 Audit report response data: ${response.data}");

      if (response.statusCode == 200) {
        if (response.data == null) {
          throw Exception('Empty response from server');
        }
        
        // Convert backend response format to expected AuditReportModel format
        final auditReport = _convertBackendResponseToAuditReport(response.data);
        print("✅ Successfully converted audit report");
        return auditReport;
      } else {
        throw Exception('Failed to get audit report: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ DioException getting audit report: $e");
      print("❌ Response data: ${e.response?.data}");
      print("❌ Response status: ${e.response?.statusCode}");
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print("❌ General error getting audit report: $e");
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<AuditReportModel>> getUserAuditReports() async {
    try {
      print("📤 Getting user audit reports");
      
      final response = await dio.get('/api/ai/audits/list/');

      print("📥 User audits response: ${response.data}");

      if (response.statusCode == 200) {
        final List<dynamic> reportsJson = response.data['audits'] ?? response.data['results'] ?? [];
        return reportsJson
            .map((json) => AuditReportModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to get audit reports: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Error getting user audit reports: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<bool> cancelAudit(String auditId) async {
    try {
      final response = await dio.delete('/api/audit/$auditId');

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<SmartContractModel> uploadContract(String name, String fileName, String sourceCode) async {
    print("🌐 AuditRemoteDataSource.uploadContract called");
    print("🔗 Base URL: ${dio.options.baseUrl}");
    print("📋 Request data: name=$name, fileName=$fileName, sourceCode=${sourceCode.length} chars");
    
    try {
      print("📤 Making POST request to /api/ai/upload-contract/ for validation");
      
      // Use the upload endpoint for validation only (doesn't start audit)
      final response = await dio.post(
        '/api/ai/upload-contract/',
        data: FormData.fromMap({
          'contract_file': MultipartFile.fromString(
            sourceCode,
            filename: fileName,
            contentType: DioMediaType('text', 'plain'),
          ),
          'contract_name': name,
        }),
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print("📥 Upload validation response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData['success'] == true) {
          print("✅ Contract validation successful");
          
          // Create a SmartContract model with unique ID for local storage
          final contractId = 'contract_${DateTime.now().millisecondsSinceEpoch}';
          
          final contractData = {
            'id': contractId,
            'name': name,
            'fileName': fileName,
            'sourceCode': sourceCode,
            'uploadedAt': DateTime.now().toIso8601String(),
            'status': 'validated',
            'fileInfo': responseData['file_info'] ?? {},
          };
          
          print("🏗️ Created contract data: $contractData");
          
          final contractModel = SmartContractModel.fromJson(contractData);
          print("✅ Successfully created SmartContractModel: ${contractModel.id}");
          
          return contractModel;
        } else {
          throw Exception('Contract validation failed: ${responseData['error'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to validate contract: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ DioException in uploadContract:");
      print("🔍 Type: ${e.type}");
      print("📱 Error: ${e.error}");
      print("💬 Message: ${e.message}");
      print("📊 Response: ${e.response?.data}");
      print("🔗 Request URL: ${e.requestOptions.uri}");
      
      throw Exception('Network error: ${e.message ?? e.error?.toString() ?? 'Unknown error'}');
    } catch (e) {
      print("❌ Unexpected error in uploadContract: $e");
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<SmartContractModel> getContract(String contractId) async {
    try {
      final response = await dio.get('/api/contracts/$contractId');

      if (response.statusCode == 200) {
        return SmartContractModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get contract: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<bool> deleteContract(String contractId) async {
    try {
      final response = await dio.delete('/api/contracts/$contractId');

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<List<ContractType>> getSupportedContractTypes() async {
    try {
      final response = await dio.get('/api/contracts/types');

      if (response.statusCode == 200) {
        final List<dynamic> typesJson = response.data['types'];
        return typesJson
            .map((typeString) => ContractType.values.firstWhere(
                  (e) => e.name == typeString,
                  orElse: () => ContractType.custom,
                ))
            .toList();
      } else {
        throw Exception('Failed to get contract types: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Converts backend response format to AuditReportModel format
  AuditReportModel _convertBackendResponseToAuditReport(Map<String, dynamic> backendData) {
    print("🔄 Converting backend response to AuditReportModel");
    print("📄 Backend data keys: ${backendData.keys.toList()}");
    
    // Extract data from backend response format - handle both nested and flat structures
    final auditData = backendData['audit'] ?? backendData;
    print("📊 Audit data keys: ${auditData.keys.toList()}");
    
    // Extract vulnerabilities - handle both AI and pattern-detected vulnerabilities
    final aiVulnerabilities = auditData['ai_vulnerabilities'] as List? ?? [];
    final patternVulnerabilities = auditData['vulnerabilities'] as List? ?? [];
    final allVulnerabilities = [...aiVulnerabilities, ...patternVulnerabilities];
    
    print("🔍 Found ${allVulnerabilities.length} total vulnerabilities");
    
    final gasOptimization = auditData['gas_optimization'] as String? ?? '';
    final recommendations = auditData['recommendations'] as String? ?? '';
    final aiRecommendations = auditData['ai_recommendations'] as List? ?? [];
    final vulnerabilitiesFound = auditData['vulnerabilities_found'] as int? ?? allVulnerabilities.length;
    
    // Convert vulnerabilities from backend format
    final convertedVulnerabilities = allVulnerabilities.map((v) {
      final vulnMap = v as Map<String, dynamic>;
      return VulnerabilityModel(
        id: vulnMap['cwe_id'] as String? ?? 'UNKNOWN-${DateTime.now().millisecondsSinceEpoch}',
        title: vulnMap['title'] as String? ?? 'Unknown Vulnerability',
        description: vulnMap['description'] as String? ?? '',
        severity: _convertSeverityFromBackend(vulnMap['severity'] as String?),
        category: vulnMap['category'] as String? ?? vulnMap['title'] as String? ?? 'Unknown',
        lineNumbers: [(vulnMap['line_number'] as int?) ?? 1],
        remediation: vulnMap['recommendation'] as String?,
      );
    }).toList();

    // Create summary data
    final criticalCount = convertedVulnerabilities.where((v) => v.severity == Severity.critical).length;
    final highCount = convertedVulnerabilities.where((v) => v.severity == Severity.high).length;
    final mediumCount = convertedVulnerabilities.where((v) => v.severity == Severity.medium).length;
    final lowCount = convertedVulnerabilities.where((v) => v.severity == Severity.low).length;

    print("📊 Vulnerability counts - Critical: $criticalCount, High: $highCount, Medium: $mediumCount, Low: $lowCount");

    // Calculate overall score based on vulnerabilities
    double calculateScore() {
      final totalIssues = criticalCount * 10 + highCount * 7 + mediumCount * 4 + lowCount * 1;
      final maxPossibleScore = 100;
      return (maxPossibleScore - totalIssues).clamp(0, 100).toDouble();
    }

    // Parse timestamp - handle both MongoDB and ISO formats
    DateTime parseTimestamp() {
      final createdAt = auditData['created_at'];
      if (createdAt == null) return DateTime.now();
      
      try {
        // Handle MongoDB date format: {"$date": {"$numberLong": "timestamp"}}
        if (createdAt is Map && createdAt['\$date'] != null) {
          final dateData = createdAt['\$date'];
          if (dateData is Map && dateData['\$numberLong'] != null) {
            final timestamp = int.parse(dateData['\$numberLong'].toString());
            return DateTime.fromMillisecondsSinceEpoch(timestamp);
          }
        }
        // Handle ISO string format
        if (createdAt is String) {
          return DateTime.parse(createdAt);
        }
        // Handle epoch timestamp
        if (createdAt is int) {
          return DateTime.fromMillisecondsSinceEpoch(createdAt);
        }
      } catch (e) {
        print("⚠️ Error parsing timestamp: $e");
      }
      
      return DateTime.now();
    }

    final calculatedScore = calculateScore();
    print("📈 Calculated overall score: $calculatedScore");

    // Create the AuditReportModel in the expected format
    return AuditReportModel(
      id: auditData['audit_id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      contractName: auditData['contract_name'] as String? ?? 'Unknown Contract',
      fileName: auditData['filename'] as String? ?? auditData['file_name'] as String? ?? 'unknown.sol',
      timestamp: parseTimestamp(),
      status: AuditStatus.completed,
      securityAnalysis: SecurityAnalysisModel(
        criticalIssues: criticalCount,
        highRiskIssues: highCount,
        mediumRiskIssues: mediumCount,
        lowRiskIssues: lowCount,
        securityScore: calculatedScore,
        completedChecks: [
          SecurityCheckModel(
            name: 'Vulnerability Scan',
            passed: vulnerabilitiesFound == 0,
            description: 'Automated vulnerability detection using pattern matching and AI analysis',
          ),
          SecurityCheckModel(
            name: 'Code Quality Analysis',
            passed: calculatedScore > 70,
            description: 'Overall code quality assessment',
          ),
        ],
      ),
      gasOptimization: GasOptimizationModel(
        optimizationScore: _calculateGasOptimizationScore(gasOptimization),
        suggestions: _parseGasOptimizationSuggestions(gasOptimization),
      ),
      codeQuality: CodeQualityModel(
        qualityScore: calculatedScore,
        linesOfCode: (auditData['source_code'] as String? ?? '').split('\n').length,
        complexityScore: _calculateComplexityScore(allVulnerabilities.length),
        issues: convertedVulnerabilities.take(5).map((v) => 
          CodeIssueModel(
            type: v.category,
            description: v.description,
            lineNumber: v.lineNumbers.isNotEmpty ? v.lineNumbers.first : 1,
            severity: v.severity,
          )
        ).toList(),
      ),
      vulnerabilities: convertedVulnerabilities,
      recommendations: _parseRecommendations(recommendations, aiRecommendations),
      overallScore: calculatedScore,
    );
  }

  /// Convert backend severity format to app Severity enum
  Severity _convertSeverityFromBackend(String? severityString) {
    if (severityString == null) return Severity.low;
    
    switch (severityString.toUpperCase()) {
      case 'CRITICAL':
        return Severity.critical;
      case 'HIGH':
        return Severity.high;
      case 'MEDIUM':
        return Severity.medium;
      case 'LOW':
        return Severity.low;
      default:
        return Severity.low;
    }
  }

  /// Parse gas optimization suggestions from backend gas optimization text
  List<GasOptimizationSuggestionModel> _parseGasOptimizationSuggestions(String gasOptText) {
    final List<GasOptimizationSuggestionModel> suggestions = [];
    
    if (gasOptText.isEmpty) {
      // Return default suggestions if no backend data
      return [
        const GasOptimizationSuggestionModel(
          function: 'State Variables',
          suggestion: 'Pack state variables to reduce storage slots',
          priority: Priority.medium,
        ),
        const GasOptimizationSuggestionModel(
          function: 'Loop Optimization',
          suggestion: 'Optimize loops to reduce gas consumption',
          priority: Priority.low,
        ),
      ];
    }

    // Parse actual backend gas optimization text
    try {
      // Split by common delimiters and extract suggestions
      final lines = gasOptText.split(RegExp(r'\n|\. |; '));
      
      for (String line in lines) {
        line = line.trim();
        if (line.isEmpty || line.length < 10) continue;
        
        // Determine priority based on content keywords
        Priority priority = Priority.medium;
        if (line.toLowerCase().contains('critical') || line.toLowerCase().contains('high')) {
          priority = Priority.high;
        } else if (line.toLowerCase().contains('low') || line.toLowerCase().contains('minor')) {
          priority = Priority.low;
        }
        
        // Extract function name (look for patterns like "in function X" or "function X")
        String functionName = 'General';
        final functionPattern = RegExp(r'(?:in\s+)?function\s+(\w+)', caseSensitive: false);
        final funcMatch = functionPattern.firstMatch(line);
        if (funcMatch != null) {
          functionName = funcMatch.group(1) ?? 'General';
        } else if (line.toLowerCase().contains('loop')) {
          functionName = 'Loop Optimization';
        } else if (line.toLowerCase().contains('storage') || line.toLowerCase().contains('variable')) {
          functionName = 'State Variables';
        } else if (line.toLowerCase().contains('modifier')) {
          functionName = 'Modifiers';
        }
        
        suggestions.add(GasOptimizationSuggestionModel(
          function: functionName,
          suggestion: line,
          priority: priority,
        ));
        
        // Limit to 5 suggestions to avoid UI clutter
        if (suggestions.length >= 5) break;
      }
    } catch (e) {
      print("⚠️ Error parsing gas optimization suggestions: $e");
    }
    
    // Return default if parsing failed
    if (suggestions.isEmpty) {
      return [
        GasOptimizationSuggestionModel(
          function: 'Analysis Result',
          suggestion: gasOptText.isNotEmpty ? gasOptText : 'No specific gas optimization suggestions available.',
          priority: Priority.medium,
        ),
      ];
    }
    
    return suggestions;
  }

  /// Calculate gas optimization score based on backend gas optimization text
  double _calculateGasOptimizationScore(String gasOptText) {
    if (gasOptText.isEmpty) return 60.0; // Default score for empty optimization data
    
    double score = 50.0; // Base score
    
    try {
      // Analyze content for optimization quality indicators
      final optimizationKeywords = [
        'optimize', 'optimization', 'efficient', 'reduce', 'save', 'improve',
        'gas', 'cost', 'performance', 'cheaper', 'better'
      ];
      
      final negativeKeywords = [
        'no optimization', 'cannot optimize', 'not possible', 'inefficient',
        'expensive', 'high cost', 'poor', 'bad'
      ];
      
      // Count positive optimization indicators
      int positiveCount = 0;
      int negativeCount = 0;
      
      final lowerText = gasOptText.toLowerCase();
      
      for (final keyword in optimizationKeywords) {
        if (lowerText.contains(keyword)) {
          positiveCount++;
        }
      }
      
      for (final keyword in negativeKeywords) {
        if (lowerText.contains(keyword)) {
          negativeCount++;
        }
      }
      
      // Calculate score based on keyword analysis
      score += (positiveCount * 8); // Boost for positive indicators
      score -= (negativeCount * 15); // Penalty for negative indicators
      
      // Bonus for specific optimization techniques mentioned
      if (lowerText.contains('storage')) score += 5;
      if (lowerText.contains('memory')) score += 5;
      if (lowerText.contains('loop')) score += 5;
      if (lowerText.contains('variable packing')) score += 10;
      if (lowerText.contains('modifier')) score += 5;
      if (lowerText.contains('function')) score += 3;
      
      // Bonus for quantified improvements (specific gas amounts)
      final gasNumberPattern = RegExp(r'\d+\s*(?:gas|wei)', caseSensitive: false);
      if (gasNumberPattern.hasMatch(gasOptText)) {
        score += 10;
      }
      
      // Bonus for detailed analysis (longer content generally means more thorough)
      if (gasOptText.length > 100) score += 5;
      if (gasOptText.length > 300) score += 5;
      if (gasOptText.length > 500) score += 5;
      
      // Clamp score to valid range
      score = score.clamp(0.0, 100.0);
      
      print("📊 Calculated gas optimization score: $score (positive: $positiveCount, negative: $negativeCount)");
      
    } catch (e) {
      print("⚠️ Error calculating gas optimization score: $e");
      score = 60.0; // Default on error
    }
    
    return score;
  }

  /// Calculate complexity score based on vulnerability count
  int _calculateComplexityScore(int vulnerabilityCount) {
    if (vulnerabilityCount == 0) return 1;
    if (vulnerabilityCount <= 2) return 3;
    if (vulnerabilityCount <= 5) return 5;
    if (vulnerabilityCount <= 10) return 7;
    return 10;
  }

  /// Parse recommendations from structured backend text and AI recommendations
  List<RecommendationModel> _parseRecommendations(String recommendationsText, [List<dynamic>? aiRecommendations]) {
    final List<RecommendationModel> recommendations = [];
    
    // Parse structured recommendations text
    if (recommendationsText.isNotEmpty) {
      try {
        // Split by sections based on the backend format
        final sections = _parseRecommendationSections(recommendationsText);
        recommendations.addAll(sections);
      } catch (e) {
        print("⚠️ Error parsing structured recommendations: $e");
        // Fallback to treating as single recommendation
        recommendations.add(RecommendationModel(
          title: 'Security Improvements',
          description: recommendationsText,
          priority: Priority.high,
          category: 'Security',
        ));
      }
    }
    
    // Add AI recommendations if available and not already included
    if (aiRecommendations != null && aiRecommendations.isNotEmpty) {
      for (int i = 0; i < aiRecommendations.length && i < 3; i++) {
        final rec = aiRecommendations[i];
        recommendations.add(RecommendationModel(
          title: 'AI Analysis ${i + 1}',
          description: rec.toString(),
          priority: Priority.medium,
          category: 'AI Analysis',
        ));
      }
    }
    
    // Add default recommendations if none exist
    if (recommendations.isEmpty) {
      recommendations.add(RecommendationModel(
        title: 'Code Quality',
        description: 'Improve code documentation and structure',
        priority: Priority.medium,
        category: 'Code Quality',
      ));
    }
    
    return recommendations;
  }

  /// Parse structured recommendation sections from backend format
  List<RecommendationModel> _parseRecommendationSections(String text) {
    final List<RecommendationModel> recommendations = [];
    
    // Split by known section headers from backend
    final sectionPatterns = {
      'HIGH PRIORITY:': {'priority': Priority.high, 'category': 'Security'},
      'AI ANALYSIS RECOMMENDATIONS:': {'priority': Priority.medium, 'category': 'AI Analysis'},
      'GAS OPTIMIZATION:': {'priority': Priority.medium, 'category': 'Gas Optimization'},
      'GENERAL RECOMMENDATIONS:': {'priority': Priority.low, 'category': 'General'},
      'MEDIUM PRIORITY:': {'priority': Priority.medium, 'category': 'Security'},
      'LOW PRIORITY:': {'priority': Priority.low, 'category': 'Security'},
    };
    
    String remainingText = text;
    
    for (final sectionPattern in sectionPatterns.entries) {
      final sectionHeader = sectionPattern.key;
      final sectionConfig = sectionPattern.value;
      
      if (remainingText.contains(sectionHeader)) {
        final sectionStart = remainingText.indexOf(sectionHeader);
        final sectionEnd = _findNextSectionStart(remainingText, sectionStart + sectionHeader.length, sectionPatterns.keys.toList());
        
        final sectionContent = remainingText.substring(
          sectionStart + sectionHeader.length,
          sectionEnd > sectionStart ? sectionEnd : remainingText.length
        ).trim();
        
        if (sectionContent.isNotEmpty) {
          // Split section content by lines and clean up
          final lines = sectionContent.split('\n')
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty && line.startsWith('- '))
              .map((line) => line.substring(2)) // Remove "- " prefix
              .toList();
          
          if (lines.isNotEmpty) {
            recommendations.add(RecommendationModel(
              title: sectionHeader.replaceAll(':', '').trim(),
              description: lines.join('\n• '), // Use bullet points
              priority: sectionConfig['priority'] as Priority,
              category: sectionConfig['category'] as String,
            ));
          }
        }
        
        // Remove processed section from remaining text
        remainingText = remainingText.substring(0, sectionStart) + 
                      (sectionEnd > sectionStart ? remainingText.substring(sectionEnd) : '');
      }
    }
    
    return recommendations;
  }

  /// Find the start of the next section
  int _findNextSectionStart(String text, int startFrom, List<String> sectionHeaders) {
    int earliest = text.length;
    
    for (final header in sectionHeaders) {
      final index = text.indexOf(header, startFrom);
      if (index >= 0 && index < earliest) {
        earliest = index;
      }
    }
    
    return earliest;
  }

  @override
  Future<bool> validateContractCode(String sourceCode) async {
    try {
      final response = await dio.post(
        '/api/contracts/validate',
        data: {
          'source_code': sourceCode,
        },
      );

      if (response.statusCode == 200) {
        return response.data['is_valid'] as bool;
      } else {
        throw Exception('Failed to validate contract: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  // Financial Reports Implementation

  @override
  Future<List<TaxReportModel>> getTaxReports() async {
    try {
      print("📤 Getting tax reports from /api/financial/tax-report/list/");
      
      final response = await dio.get('/api/financial/tax-report/list/');

      print("📥 Tax reports response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");
      print("📄 Response data type: ${response.data.runtimeType}");

      if (response.statusCode == 200) {
        // Check if response data is null or empty
        if (response.data == null) {
          print("❌ Response data is null");
          throw Exception('Empty response from tax reports endpoint');
        }
        
        // Log the actual structure
        if (response.data is Map) {
          final data = response.data as Map;
          print("🔍 Response keys: ${data.keys.toList()}");
          print("🔍 Success field: ${data['success']} (${data['success'].runtimeType})");
          print("🔍 Count field: ${data['count']} (${data['count'].runtimeType})");
          print("🔍 Results field: ${data['results']} (${data['results'].runtimeType})");
          print("🔍 Tax reports field: ${data['tax_reports']} (${data['tax_reports'].runtimeType})");
        }
        
        // Safely cast the response data with error handling
        Map<String, dynamic> responseData;
        try {
          responseData = Map<String, dynamic>.from(response.data as Map);
        } catch (e) {
          print("❌ Error casting response data: $e");
          print("📊 Response data type: ${response.data.runtimeType}");
          print("📊 Response data: ${response.data}");
          throw Exception('Failed to parse response data: $e');
        }
        
        print("📊 Tax reports response structure: ${responseData.keys.toList()}");
        print("📊 Tax reports success: ${responseData['success']}");
        
        // Handle multiple possible response formats
        if (responseData['success'] == true) {
          // Try different possible field names for the tax reports array
          List<dynamic> taxReports = [];
          
          if (responseData['tax_reports'] != null) {
            taxReports = List<dynamic>.from(responseData['tax_reports'] as List);
            print("📊 Found ${taxReports.length} tax reports in 'tax_reports' field");
          } else if (responseData['results'] != null) {
            taxReports = List<dynamic>.from(responseData['results'] as List);
            print("📊 Found ${taxReports.length} tax reports in 'results' field");
          } else if (responseData['data'] != null) {
            taxReports = List<dynamic>.from(responseData['data'] as List);
            print("📊 Found ${taxReports.length} tax reports in 'data' field");
          } else {
            print("⚠️ No tax reports array found in response");
            print("📊 Available fields: ${responseData.keys.toList()}");
            return []; // Return empty list if no reports
          }
          
          if (taxReports.isNotEmpty) {
            return taxReports.map((reportData) {
              try {
                print("🔄 Parsing tax report: ${reportData.runtimeType}");
                return TaxReportModel.fromJson(Map<String, dynamic>.from(reportData as Map));
              } catch (e) {
                print("❌ Error parsing tax report: $e");
                print("📊 Report data: $reportData");
                // Return a basic report if parsing fails
                return _createEmptyTaxReport();
              }
            }).toList();
          } else {
            print("📊 Tax reports array is empty");
            return []; // Return empty list if no reports
          }
        } else if (responseData['success'] == true && responseData.isEmpty) {
          // Handle empty response - return empty list
          print("⚠️ Empty tax reports response, returning empty list");
          return [];
        } else {
          print("❌ Invalid response format - success is not true");
          print("📊 Response keys: ${responseData.keys.toList()}");
          throw Exception('Invalid response format: (success=${responseData['success']}, keys=${responseData.keys})');
        }
      } else {
        throw Exception('Failed to get tax reports: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ DioException getting tax reports: $e");
      print("📊 DioException type: ${e.type}");
      print("📊 DioException message: ${e.message}");
      print("📊 DioException response: ${e.response?.data}");
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      print("❌ General error getting tax reports: $e");
      print("📄 Stack trace: $stackTrace");
      throw Exception('Failed to get tax reports: $e');
    }
  }

  /// Create an empty tax report when no data is available
  TaxReportModel _createEmptyTaxReport() {
    final emptyData = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'report_type': 'Tax Report',
      'report_date': DateTime.now().toIso8601String(),
      'period_start': DateTime.now().toIso8601String(),
      'period_end': DateTime.now().toIso8601String(),
      'currency': 'USD',
      'summary': {
        'total_income': 0.0,
        'total_deductions': 0.0,
        'taxable_income': 0.0,
        'total_tax_owed': 0.0,
        'total_tax_paid': 0.0,
        'net_tax_owed': 0.0,
        'tax_breakdown': {},
        'income_breakdown': {},
        'deduction_breakdown': {},
      },
      'categories': [],
      'transactions': [],
      'metadata': {
        'user_id': 'unknown',
        'generated_at': DateTime.now().toIso8601String(),
        'note': 'Empty tax report - no data available',
      },
      'created_at': DateTime.now().toIso8601String(),
      'generated_at': DateTime.now().toIso8601String(),
    };
    
    return TaxReportModel.fromJson(emptyData);
  }

  @override
  Future<BalanceSheetModel> getBalanceSheet() async {
    try {
      print("📤 Getting balance sheet from /api/balance-sheet/list/");
      
      final response = await dio.get('/api/balance-sheet/list/');

      print("📥 Balance sheet response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200) {
        // Safely cast the response data
        final responseData = Map<String, dynamic>.from(response.data as Map);
        
        // Handle the actual API response structure
        if (responseData['success'] == true && responseData['balance_sheets'] != null) {
          final balanceSheets = List<dynamic>.from(responseData['balance_sheets'] as List);
          if (balanceSheets.isNotEmpty) {
            // Use the new model structure directly
            return BalanceSheetModel.fromJson(Map<String, dynamic>.from(balanceSheets.first as Map));
          } else {
            print("📊 No balance sheets found, returning empty model");
            return _createEmptyBalanceSheetModel();
          }
        } else {
          // If the response is directly the balance sheet data
          return BalanceSheetModel.fromJson(responseData);
        }
      } else {
        throw Exception('Failed to get balance sheet: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Error getting balance sheet: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<List<BalanceSheetModel>> getAllBalanceSheets() async {
    try {
      print("📤 Getting all balance sheets from /api/balance-sheet/list/");
      
      final response = await dio.get('/api/balance-sheet/list/');

      print("📥 All balance sheets response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200) {
        // Safely cast the response data
        final responseData = Map<String, dynamic>.from(response.data as Map);
        
        // Handle the actual API response structure
        if (responseData['success'] == true && responseData['balance_sheets'] != null) {
          final balanceSheets = List<dynamic>.from(responseData['balance_sheets'] as List);
          
          // Convert all balance sheets to models
          final List<BalanceSheetModel> balanceSheetModels = balanceSheets
              .map((sheet) => BalanceSheetModel.fromJson(Map<String, dynamic>.from(sheet as Map)))
              .toList();
          
          // Sort by date (oldest first) for proper chronological order
          balanceSheetModels.sort((a, b) => a.asOfDate.compareTo(b.asOfDate));
          
          print("📊 Loaded ${balanceSheetModels.length} balance sheets");
          return balanceSheetModels;
        } else {
          print("📊 No balance sheets found in response");
          return [];
        }
      } else {
        throw Exception('Failed to get balance sheets: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Error getting all balance sheets: $e");
      throw Exception('Network error: ${e.message}');
    }
  }


  @override
  Future<CashFlowModel> getCashFlow() async {
    try {
      print("📤 Getting cash flow from /api/cash-flow/list/");
      
      final response = await dio.get('/api/cash-flow/list/');

      print("📥 Cash flow response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200) {
        // Safely cast the response data with error handling
        Map<String, dynamic> responseData;
        try {
          responseData = Map<String, dynamic>.from(response.data as Map);
        } catch (e) {
          print("❌ Error casting cash flow response data: $e");
          print("📊 Response data type: ${response.data.runtimeType}");
          print("📊 Response data: ${response.data}");
          throw Exception('Failed to parse cash flow response data: $e');
        }
        
        // Handle the actual API response structure - Cash Flow endpoint returns cash_flow_statements
        if (responseData['success'] == true && responseData['cash_flow_statements'] != null) {
          final cashFlowStatements = List<dynamic>.from(responseData['cash_flow_statements'] as List);
          if (cashFlowStatements.isNotEmpty) {
            // Take the first cash flow statement and convert it to cash flow model format
            final cashFlowData = Map<String, dynamic>.from(cashFlowStatements.first as Map);
            return _convertToCashFlowModel(cashFlowData);
          } else {
            print("📊 No cash flow statements found, returning empty model");
            return _createEmptyCashFlowModel();
          }
        } else if (responseData['success'] == true && responseData['balance_sheets'] != null) {
          // Fallback: if it returns balance sheets instead
          final balanceSheets = List<dynamic>.from(responseData['balance_sheets'] as List);
          if (balanceSheets.isNotEmpty) {
            final balanceSheetData = Map<String, dynamic>.from(balanceSheets.first as Map);
            return _convertToCashFlowModel(balanceSheetData);
          } else {
            print("📊 No balance sheets found in fallback, returning empty cash flow model");
            return _createEmptyCashFlowModel();
          }
        } else {
          throw Exception('Invalid response format: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to get cash flow: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Error getting cash flow: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Convert API cash flow data to CashFlowModel format
  CashFlowModel _convertToCashFlowModel(Map<String, dynamic> apiData) {
    try {
      print("🔄 Converting API data to CashFlowModel");
      print("📊 API data keys: ${apiData.keys.toList()}");
      
      // Check if this is actual cash flow data or balance sheet data
      if (apiData.containsKey('operating_activities')) {
        // This is actual cash flow data
        final operatingActivities = _safeConvertMap(apiData['operating_activities']);
        final investingActivities = _safeConvertMap(apiData['investing_activities']);
        final financingActivities = _safeConvertMap(apiData['financing_activities']);
        final cashSummary = _safeConvertMap(apiData['cash_summary']);
        final metadata = _safeConvertMap(apiData['metadata']);

        print("📊 Operating activities: $operatingActivities");
        print("📊 Investing activities: $investingActivities");
        print("📊 Financing activities: $financingActivities");

        // Create proper cash flow structure from actual cash flow data
        final convertedData = {
          'id': apiData['cash_flow_id'] ?? apiData['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'report_type': 'Cash Flow Statement',
          'report_date': apiData['generated_at']?.toString() ?? DateTime.now().toIso8601String(),
          'period_start': apiData['period_start']?.toString() ?? DateTime.now().toIso8601String(),
          'period_end': apiData['period_end']?.toString() ?? DateTime.now().toIso8601String(),
          'currency': apiData['currency']?.toString() ?? 'USD',
          'summary': {
            'net_cash_from_operations': _safeToDouble(operatingActivities['net_cash_flow']),
            'net_cash_from_investing': _safeToDouble(investingActivities['net_cash_flow']),
            'net_cash_from_financing': _safeToDouble(financingActivities['net_cash_flow']),
            'net_change_in_cash': _safeToDouble(cashSummary['net_change_in_cash']),
            'beginning_cash': _safeToDouble(cashSummary['beginning_cash']),
            'ending_cash': _safeToDouble(cashSummary['ending_cash']),
            'operating_breakdown': {
              'cash_receipts': _safeToDouble(operatingActivities['cash_receipts']?['total']),
              'cash_payments': _safeToDouble(operatingActivities['cash_payments']?['total']),
            },
            'investing_breakdown': {
              'cash_receipts': _safeToDouble(investingActivities['cash_receipts']?['total']),
              'cash_payments': _safeToDouble(investingActivities['cash_payments']?['total']),
            },
            'financing_breakdown': {
              'cash_receipts': _safeToDouble(financingActivities['cash_receipts']?['total']),
              'cash_payments': _safeToDouble(financingActivities['cash_payments']?['total']),
            },
          },
          'operating_activities': _convertOperatingActivities(operatingActivities),
          'investing_activities': _convertInvestingActivities(investingActivities),
          'financing_activities': _convertFinancingActivities(financingActivities),
          'metadata': {
            'user_id': apiData['user_id']?.toString(),
            'generated_at': apiData['generated_at']?.toString(),
            'transaction_count': metadata['transaction_count']?.toString(),
            'payroll_entries': metadata['payroll_entries']?.toString(),
          },
          'created_at': apiData['generated_at']?.toString() ?? DateTime.now().toIso8601String(),
          'generated_at': apiData['generated_at']?.toString(),
        };

        print("✅ Converted cash flow data: $convertedData");
        return CashFlowModel.fromJson(convertedData);
      } else {
        // This is balance sheet data being returned instead
        final assets = _safeConvertMap(apiData['assets']);
        final metadata = _safeConvertMap(apiData['metadata']);

        print("📊 Assets: $assets");
        print("⚠️ Note: Cash Flow endpoint returned balance sheet data");

        // Create a basic cash flow structure from balance sheet data
        final convertedData = {
          'id': apiData['balance_sheet_id'] ?? apiData['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'report_type': 'Cash Flow Statement',
          'report_date': apiData['as_of_date']?.toString() ?? apiData['generated_at']?.toString() ?? DateTime.now().toIso8601String(),
          'period_start': apiData['as_of_date']?.toString() ?? DateTime.now().toIso8601String(),
          'period_end': apiData['as_of_date']?.toString() ?? DateTime.now().toIso8601String(),
          'currency': apiData['currency']?.toString() ?? 'USD',
          'summary': {
            'net_cash_from_operations': 0.0, // Not available in balance sheet data
            'net_cash_from_investing': 0.0, // Not available in balance sheet data
            'net_cash_from_financing': 0.0, // Not available in balance sheet data
            'net_change_in_cash': 0.0, // Not available in balance sheet data
            'beginning_cash': _safeToDouble(assets['current_assets']?['cash_equivalents']),
            'ending_cash': _safeToDouble(assets['current_assets']?['cash_equivalents']),
            'operating_breakdown': {
              'cash_receipts': 0.0,
              'cash_payments': 0.0,
            },
            'investing_breakdown': {
              'cash_receipts': 0.0,
              'cash_payments': 0.0,
            },
            'financing_breakdown': {
              'cash_receipts': 0.0,
              'cash_payments': 0.0,
            },
          },
          'operating_activities': [],
          'investing_activities': [],
          'financing_activities': [],
          'metadata': {
            'user_id': apiData['user_id']?.toString(),
            'generated_at': apiData['generated_at']?.toString(),
            'transaction_count': metadata['transaction_count']?.toString(),
            'note': 'Cash flow data not available - showing balance sheet data instead',
          },
          'created_at': apiData['generated_at']?.toString() ?? DateTime.now().toIso8601String(),
          'generated_at': apiData['generated_at']?.toString(),
        };

        print("✅ Converted balance sheet to cash flow data: $convertedData");
        return CashFlowModel.fromJson(convertedData);
      }
    } catch (e, stackTrace) {
      print("❌ Error converting cash flow data: $e");
      print("📊 Stack trace: $stackTrace");
      rethrow;
    }
  }

  /// Create an empty balance sheet model when no data is available
  BalanceSheetModel _createEmptyBalanceSheetModel() {
    print("📊 Creating empty balance sheet model - no data available");
    
    final emptyData = {
      '_id': 'empty_balance_sheet_${DateTime.now().millisecondsSinceEpoch}',
      'balance_sheet_id': 'empty_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': 'unknown',
      'as_of_date': DateTime.now().toIso8601String(),
      'report_type': 'CUSTOM',
      'period_start': DateTime.now().toIso8601String(),
      'period_end': DateTime.now().toIso8601String(),
      'generated_at': DateTime.now().toIso8601String(),
      'currency': 'USD',
      'assets': {
        'current_assets': {
          'crypto_holdings': {'total_value': 0.0},
          'cash_equivalents': 0.0,
          'receivables': 0,
          'total': 0.0
        },
        'non_current_assets': {
          'long_term_investments': 0.0,
          'equipment': 0.0,
          'other': 0.0,
          'total': 0.0
        },
        'total': 0.0
      },
      'liabilities': {
        'current_liabilities': {
          'accounts_payable': 0,
          'accrued_expenses': 0.0,
          'short_term_debt': 0.0,
          'tax_liabilities': 0.0,
          'total': 0.0
        },
        'long_term_liabilities': {
          'long_term_debt': 0.0,
          'deferred_tax': 0.0,
          'other': 0.0,
          'total': 0.0
        },
        'total': 0.0
      },
      'equity': {
        'retained_earnings': 0,
        'unrealized_gains_losses': 0.0,
        'total': 0.0
      },
      'totals': {
        'total_assets': 0.0,
        'total_liabilities': 0.0,
        'total_equity': 0.0,
        'balance_check': 0.0
      },
      'summary': {
        'financial_position': 'No data available',
        'debt_to_equity_ratio': 'Undefined',
        'asset_composition': {
          'crypto_percentage': 0,
          'cash_percentage': 0
        },
        'liquidity_ratio': 'Unlimited',
        'net_worth': 0.0
      },
      'metadata': {
        'transaction_count': 0,
        'date_range': {
          'earliest_transaction': DateTime.now().toIso8601String(),
          'latest_transaction': DateTime.now().toIso8601String()
        }
      }
    };
    
    return BalanceSheetModel.fromJson(emptyData);
  }

  /// Create an empty cash flow model when no data is available
  CashFlowModel _createEmptyCashFlowModel() {
    print("📊 Creating empty cash flow model - no data available");
    
    final emptyData = {
      'id': 'empty_cash_flow_${DateTime.now().millisecondsSinceEpoch}',
      'report_type': 'Cash Flow Statement',
      'report_date': DateTime.now().toIso8601String(),
      'period_start': DateTime.now().toIso8601String(),
      'period_end': DateTime.now().toIso8601String(),
      'currency': 'USD',
      'summary': {
        'net_cash_from_operations': 0.0,
        'net_cash_from_investing': 0.0,
        'net_cash_from_financing': 0.0,
        'net_change_in_cash': 0.0,
        'beginning_cash': 0.0,
        'ending_cash': 0.0,
        'operating_breakdown': {
          'cash_receipts': 0.0,
          'cash_payments': 0.0,
        },
        'investing_breakdown': {
          'cash_receipts': 0.0,
          'cash_payments': 0.0,
        },
        'financing_breakdown': {
          'cash_receipts': 0.0,
          'cash_payments': 0.0,
        },
      },
      'operating_activities': [],
      'investing_activities': [],
      'financing_activities': [],
      'metadata': {
        'user_id': 'unknown',
        'generated_at': DateTime.now().toIso8601String(),
        'note': 'No cash flow data available yet',
        'empty_data': true,
      },
      'created_at': DateTime.now().toIso8601String(),
      'generated_at': DateTime.now().toIso8601String(),
    };
    
    return CashFlowModel.fromJson(emptyData);
  }


  /// Helper method to safely convert any map to Map<String, dynamic>
  Map<String, dynamic> _safeConvertMap(dynamic value) {
    try {
      if (value == null) return <String, dynamic>{};
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        // Recursively convert nested maps to ensure all values are properly typed
        final Map<String, dynamic> result = {};
        for (final entry in value.entries) {
          final key = entry.key?.toString() ?? 'unknown';
          final val = entry.value;
          if (val is Map) {
            result[key] = _safeConvertMap(val);
          } else if (val is List) {
            result[key] = _safeConvertList(val);
          } else {
            result[key] = val;
          }
        }
        return result;
      }
      return <String, dynamic>{};
    } catch (e) {
      print("❌ Error in _safeConvertMap: $e");
      return <String, dynamic>{};
    }
  }

  /// Helper method to safely convert any list to List<dynamic>
  List<dynamic> _safeConvertList(dynamic value) {
    try {
      if (value == null) return <dynamic>[];
      if (value is List) {
        return value.map((item) {
          if (item is Map) {
            return _safeConvertMap(item);
          } else if (item is List) {
            return _safeConvertList(item);
          } else {
            return item;
          }
        }).toList();
      }
      return <dynamic>[];
    } catch (e) {
      print("❌ Error in _safeConvertList: $e");
      return <dynamic>[];
    }
  }

  /// Helper method to safely convert any value to double
  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }



  /// Convert operating activities to list format
  List<Map<String, dynamic>> _convertOperatingActivities(Map<String, dynamic> operatingData) {
    try {
      final List<Map<String, dynamic>> activities = [];
      
      // Add cash receipts
      final cashReceipts = _safeConvertMap(operatingData['cash_receipts']);
      final customerPayments = _safeToDouble(cashReceipts['customer_payments']);
      if (customerPayments > 0) {
        activities.add({
          'id': 'op_rec_1',
          'description': 'Customer Payments',
          'amount': customerPayments,
          'category': 'Operating',
          'sub_category': 'Cash Receipts',
          'transaction_date': DateTime.now().toIso8601String(),
          'currency': 'USD',
          'metadata': {},
        });
      }
      
      // Add cash payments
      final cashPayments = _safeConvertMap(operatingData['cash_payments']);
      final payrollPayments = _safeToDouble(cashPayments['payroll_payments']);
      if (payrollPayments > 0) {
        activities.add({
          'id': 'op_pay_1',
          'description': 'Payroll Payments',
          'amount': -payrollPayments, // Negative for payments
          'category': 'Operating',
          'sub_category': 'Cash Payments',
          'transaction_date': DateTime.now().toIso8601String(),
          'currency': 'USD',
          'metadata': {},
        });
      }
      
      return activities;
    } catch (e) {
      print("❌ Error converting operating activities: $e");
      return [];
    }
  }

  /// Convert investing activities to list format
  List<Map<String, dynamic>> _convertInvestingActivities(Map<String, dynamic> investingData) {
    try {
      final List<Map<String, dynamic>> activities = [];
      
      final cashReceipts = _safeConvertMap(investingData['cash_receipts']);
      final assetSales = _safeToDouble(cashReceipts['asset_sales']);
      
      // Add activities based on available data
      if (assetSales > 0) {
        activities.add({
          'id': 'inv_rec_1',
          'description': 'Asset Sales',
          'amount': assetSales,
          'category': 'Investing',
          'sub_category': 'Asset Sales',
          'transaction_date': DateTime.now().toIso8601String(),
          'currency': 'USD',
          'metadata': {},
        });
      }
      
      return activities;
    } catch (e) {
      print("❌ Error converting investing activities: $e");
      return [];
    }
  }

  /// Convert financing activities to list format
  List<Map<String, dynamic>> _convertFinancingActivities(Map<String, dynamic> financingData) {
    try {
      final List<Map<String, dynamic>> activities = [];
      
      final cashReceipts = _safeConvertMap(financingData['cash_receipts']);
      final loansReceived = _safeToDouble(cashReceipts['loans_received']);
      
      // Add activities based on available data
      if (loansReceived > 0) {
        activities.add({
          'id': 'fin_rec_1',
          'description': 'Loans Received',
          'amount': loansReceived,
          'category': 'Financing',
          'sub_category': 'Loans',
          'transaction_date': DateTime.now().toIso8601String(),
          'currency': 'USD',
          'metadata': {},
        });
      }
      
      return activities;
    } catch (e) {
      print("❌ Error converting financing activities: $e");
      return [];
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
          print("📄 Response data type: ${response.data.runtimeType}");
          
          // Log the actual structure
          if (response.data is Map) {
            final data = response.data as Map;
            print("🔍 Response keys: ${data.keys.toList()}");
            if (data.containsKey('payslips') && data['payslips'] is List) {
              final payslips = data['payslips'] as List;
              print("📋 Payslips count: ${payslips.length}");
              if (payslips.isNotEmpty) {
                print("📄 First payslip keys: ${(payslips.first as Map).keys.toList()}");
              }
            }
          }

          if (response.statusCode == 200) {
            // Safely cast the response data
            final responseData = Map<String, dynamic>.from(response.data as Map);
            
            print("🔍 Response data type: ${responseData.runtimeType}");
            print("🔍 Success field: ${responseData['success']} (${responseData['success'].runtimeType})");
            print("🔍 Payslips field: ${responseData['payslips']} (${responseData['payslips'].runtimeType})");
            
            // Handle the actual API response structure
            if (responseData['success'] == true) {
              print("✅ Success field is true, parsing payslips...");
              return PayslipsResponseModel.fromJson(responseData);
            } else {
              throw Exception('Failed to get payslips: ${responseData['message'] ?? 'Unknown error'}');
            }
          } else {
            throw Exception('Failed to get payslips: ${response.statusMessage}');
          }
        } on DioException catch (e) {
          print("❌ DioException getting payslips: $e");
          throw Exception('Network error: ${e.message}');
        } catch (e, stackTrace) {
          print("❌ General error getting payslips: $e");
          print("📄 Stack trace: $stackTrace");
          throw Exception('Failed to get payslips: $e');
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
      print("📄 Response data type: ${response.data.runtimeType}");

      if (response.statusCode == 200) {
        // Handle both array response and wrapped response
        if (response.data is List) {
          // Direct array response
          final incomeStatements = response.data as List;
          print("📋 Found ${incomeStatements.length} income statements");
          
          return IncomeStatementsResponseModel(
            success: true,
            incomeStatements: incomeStatements
                .map((item) => IncomeStatementModel.fromJson(item as Map<String, dynamic>))
                .toList(),
          );
        } else if (response.data is Map<String, dynamic>) {
          // Wrapped response
          final responseData = response.data as Map<String, dynamic>;
          
          if (responseData['success'] == true) {
            final incomeStatements = responseData['income_statements'] as List? ?? [];
            print("📋 Found ${incomeStatements.length} income statements");
            
            return IncomeStatementsResponseModel(
              success: true,
              incomeStatements: incomeStatements
                  .map((item) => IncomeStatementModel.fromJson(item as Map<String, dynamic>))
                  .toList(),
            );
          } else {
            throw Exception('Failed to get income statements: ${responseData['message'] ?? 'Unknown error'}');
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to get income statements: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ DioException getting income statements: $e");
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      print("❌ General error getting income statements: $e");
      print("📄 Stack trace: $stackTrace");
      throw Exception('Failed to get income statements: $e');
    }
  }

  @override
  Future<InvestmentReportsResponseModel> getInvestmentReports() async {
    try {
      print("📤 Getting investment reports from /api/financial/investment-report/list/");
      
      final response = await dio.get('/api/financial/investment-report/list/');

      print("📥 Investment reports response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");
      print("📄 Response data type: ${response.data.runtimeType}");

      if (response.statusCode == 200) {
        // Handle both array response and wrapped response
        if (response.data is List) {
          // Direct array response
          final investmentReports = response.data as List;
          print("📋 Found ${investmentReports.length} investment reports");
          
          return InvestmentReportsResponseModel(
            success: true,
            investmentReports: investmentReports
                .map((item) => InvestmentReportModel.fromJson(item as Map<String, dynamic>))
                .toList(),
          );
        } else if (response.data is Map<String, dynamic>) {
          // Wrapped response
          final responseData = response.data as Map<String, dynamic>;
          
          if (responseData['success'] == true) {
            final investmentReports = responseData['investment_reports'] as List? ?? [];
            print("📋 Found ${investmentReports.length} investment reports");
            
            return InvestmentReportsResponseModel(
              success: true,
              investmentReports: investmentReports
                  .map((item) => InvestmentReportModel.fromJson(item as Map<String, dynamic>))
                  .toList(),
            );
          } else {
            throw Exception('Failed to get investment reports: ${responseData['message'] ?? 'Unknown error'}');
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to get investment reports: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ DioException getting investment reports: $e");
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      print("❌ General error getting investment reports: $e");
      print("📄 Stack trace: $stackTrace");
      throw Exception('Failed to get investment reports: $e');
    }
  }
}
