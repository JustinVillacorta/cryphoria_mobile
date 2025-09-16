import 'package:dio/dio.dart';
import '../models/audit/audit_report_model.dart';
import '../models/audit/smart_contract_model.dart';
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

      print("📥 Audit report response: ${response.data}");

      if (response.statusCode == 200) {
        // Convert backend response format to expected AuditReportModel format
        return _convertBackendResponseToAuditReport(response.data);
      } else {
        throw Exception('Failed to get audit report: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Error getting audit report: $e");
      throw Exception('Network error: ${e.message}');
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

  /// Parse recommendations from string and AI recommendations
  List<RecommendationModel> _parseRecommendations(String recommendationsText, [List<dynamic>? aiRecommendations]) {
    final List<RecommendationModel> recommendations = [];
    
    // Add main recommendation based on text
    if (recommendationsText.isNotEmpty) {
      recommendations.add(RecommendationModel(
        title: 'Security Improvements',
        description: recommendationsText,
        priority: Priority.high,
        category: 'Security',
      ));
    }
    
    // Add AI recommendations if available
    if (aiRecommendations != null && aiRecommendations.isNotEmpty) {
      for (int i = 0; i < aiRecommendations.length && i < 3; i++) {
        final rec = aiRecommendations[i];
        recommendations.add(RecommendationModel(
          title: 'AI Recommendation ${i + 1}',
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
}
