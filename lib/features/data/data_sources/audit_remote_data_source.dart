import 'package:dio/dio.dart';
import '../models/audit/audit_report_model.dart';
import '../models/audit/smart_contract_model.dart';
import '../models/tax_report_model.dart';
import '../models/cash_flow_model.dart';
import '../models/balance_sheet_model.dart';
import '../models/portfolio_model.dart';
import '../models/payslip_model.dart';
import '../models/income_statement_model.dart';
import '../../domain/entities/smart_contract.dart';
import '../../domain/entities/audit_report.dart';

abstract class AuditRemoteDataSource {
  Future<String> submitAuditRequest(AuditRequestModel request);
  Future<AuditStatus> getAuditStatus(String auditId);
  Future<AuditReportModel> getAuditReport(String auditId);
  Future<List<AuditReportModel>> getUserAuditReports();
  Future<bool> cancelAudit(String auditId);
  Future<List<SmartContractModel>> getContracts();
  Future<SmartContractModel> uploadContract(String name, String fileName, String sourceCode);
  Future<SmartContractModel> getContract(String contractId);
  Future<bool> deleteContract(String contractId);
  Future<List<ContractType>> getSupportedContractTypes();
  Future<bool> validateContractCode(String sourceCode);
  
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
  Future<AuditReportModel> getAuditReport(String auditId) async {
    print("🌐 AuditRemoteDataSource.getAuditReport called with auditId: $auditId");
    
    try {
      print("📤 Making GET request to /api/ai/audit-report/$auditId");
      
      final response = await dio.get('/api/ai/audit-report/$auditId');

      print("📥 Get audit report response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200) {
        return AuditReportModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get audit report: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ DioException in getAuditReport: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<AuditStatus> getAuditStatus(String auditId) async {
    print("🌐 AuditRemoteDataSource.getAuditStatus called with auditId: $auditId");
    
    try {
      print("📤 Making GET request to /api/ai/audit-status/$auditId");
      
      final response = await dio.get('/api/ai/audit-status/$auditId');
      
      print("📥 Response received: ${response.statusCode}");
      print("📄 Response data: ${response.data}");
      
      if (response.statusCode == 200) {
        // Parse the status string and convert to enum
        final statusString = response.data['status'] as String;
        return AuditStatus.values.firstWhere(
          (status) => status.name.toLowerCase() == statusString.toLowerCase(),
          orElse: () => AuditStatus.pending,
        );
      } else {
        throw Exception('Failed to get audit status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("❌ DioException in getAuditStatus: ${e.message}");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<List<AuditReportModel>> getUserAuditReports() async {
    print("🌐 AuditRemoteDataSource.getUserAuditReports called");
    
    try {
      print("📤 Making GET request to /api/ai/audit-reports/");
      
      final response = await dio.get('/api/ai/audit-reports/');
      
      print("📥 Response received: ${response.statusCode}");
      print("📄 Response data: ${response.data}");
      
      if (response.statusCode == 200) {
        final List<dynamic> reportsJson = response.data;
        return reportsJson.map((json) => AuditReportModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to get user audit reports: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("❌ DioException in getUserAuditReports: ${e.message}");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<bool> cancelAudit(String auditId) async {
    print("🌐 AuditRemoteDataSource.cancelAudit called with auditId: $auditId");
    
    try {
      print("📤 Making POST request to /api/ai/cancel-audit/$auditId");
      
      final response = await dio.post('/api/ai/cancel-audit/$auditId');
      
      print("📥 Response received: ${response.statusCode}");
      print("📄 Response data: ${response.data}");
      
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("❌ DioException in cancelAudit: ${e.message}");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<List<SmartContractModel>> getContracts() async {
    print("🌐 AuditRemoteDataSource.getContracts called");
    
    try {
      print("📤 Making GET request to /api/contracts/");
      
      final response = await dio.get('/api/contracts/');

      print("📥 Get contracts response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200) {
        final List<dynamic> contracts = response.data as List<dynamic>;
        return contracts.map((contract) => SmartContractModel.fromJson(contract as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to get contracts: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ DioException in getContracts: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<SmartContractModel> uploadContract(String name, String fileName, String sourceCode) async {
    print("🌐 AuditRemoteDataSource.uploadContract called");
    print("📋 Contract name: $name, fileName: $fileName");
    
    try {
      print("📤 Making POST request to /api/contracts/upload/");
      
      final response = await dio.post(
        '/api/contracts/upload/',
        data: {
          'name': name,
          'file_name': fileName,
          'source_code': sourceCode,
        },
      );

      print("📥 Upload contract response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200) {
        return SmartContractModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to upload contract: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ DioException in uploadContract: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<SmartContractModel> getContract(String contractId) async {
    print("🌐 AuditRemoteDataSource.getContract called with contractId: $contractId");
    
    try {
      print("📤 Making GET request to /api/contracts/$contractId");
      
      final response = await dio.get('/api/contracts/$contractId');

      print("📥 Get contract response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200) {
        return SmartContractModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get contract: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ DioException in getContract: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<bool> deleteContract(String contractId) async {
    print("🌐 AuditRemoteDataSource.deleteContract called with contractId: $contractId");
    
    try {
      print("📤 Making DELETE request to /api/contracts/$contractId");
      
      final response = await dio.delete('/api/contracts/$contractId');

      print("📥 Delete contract response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      return response.statusCode == 200;
    } on DioException catch (e) {
      print("❌ DioException in deleteContract: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<List<ContractType>> getSupportedContractTypes() async {
    print("🌐 AuditRemoteDataSource.getSupportedContractTypes called");
    
    try {
      print("📤 Making GET request to /api/contracts/types/");
      
      final response = await dio.get('/api/contracts/types/');

      print("📥 Get contract types response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200) {
        final List<dynamic> types = response.data as List<dynamic>;
        return types.map((type) {
          final typeString = type['type'] as String? ?? type.toString();
          return ContractType.values.firstWhere(
            (e) => e.name.toLowerCase() == typeString.toLowerCase(),
            orElse: () => ContractType.custom,
          );
        }).toList();
      } else {
        throw Exception('Failed to get contract types: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ DioException in getSupportedContractTypes: $e");
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<bool> validateContractCode(String sourceCode) async {
    print("🌐 AuditRemoteDataSource.validateContractCode called");
    
    try {
      print("📤 Making POST request to /api/contracts/validate/");
      
      final response = await dio.post(
        '/api/contracts/validate/',
        data: {
          'source_code': sourceCode,
        },
      );

      print("📥 Validate contract response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return responseData['valid'] as bool? ?? false;
      } else {
        throw Exception('Failed to validate contract: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ DioException in validateContractCode: $e");
      throw Exception('Network error: ${e.message}');
    }
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
        final List<dynamic> reports = response.data as List<dynamic>;
        return reports.map((report) => TaxReportModel.fromJson(report as Map<String, dynamic>)).toList();
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