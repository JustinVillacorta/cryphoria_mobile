import 'package:dio/dio.dart';
import '../../domain/entities/employee.dart';

abstract class EmployeeRemoteDataSource {
  Future<List<Employee>> getAllEmployees();
  Future<List<Employee>> getManagerTeam(); // New: Get employees managed by current manager
  Future<Employee> addEmployeeToTeam(AddEmployeeToTeamRequest request); // Register new employee (backend doesn't have team-specific endpoint)
  Future<Employee> registerEmployee(EmployeeRegistrationRequest request); // Keep for self-registration
  Future<void> updateEmployeeRole(String username, String newRole);
  Future<List<Employee>> getEmployeesByManager();
  Future<void> updateEmployeeStatus(String username, bool isActive); // Updated parameter from employeeId to username
  Future<PayrollInfo> createPayrollEntry(PayrollCreateRequest request);
  Future<List<PayrollInfo>> getPayrollEntries();
  Future<Payslip> createPayslip(PayslipCreateRequest request);
  Future<List<Payslip>> getPayslips({String? employeeId, String? status});
  Future<String> generatePayslipPdf(String payslipId);
  Future<void> sendPayslipEmail(String payslipId);
  Future<void> processPayslipPayment(String payslipId);
  Future<PayrollBatchResult> processBatchPayroll(PayrollBatchRequest request);
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final Dio dio;

  EmployeeRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Employee>> getAllEmployees() async {
    try {
      final response = await dio.get('/api/auth/users/');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['users'] != null) {
          return (data['users'] as List)
              .map((json) => Employee.fromJson(json))
              .toList();
        }
      }
      
      throw Exception('Failed to load employees: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<List<Employee>> getManagerTeam() async {
    try {
      // Use the correct endpoint for manager's team
      final response = await dio.get('/api/auth/employees/list/');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['employees'] != null) {
          // Backend already filters for manager's team
          return (data['employees'] as List)
              .map((json) => Employee.fromJson(json))
              .toList();
        }
      }
      
      throw Exception('Failed to load team employees: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<Employee> addEmployeeToTeam(AddEmployeeToTeamRequest request) async {
    try {
      // Use the correct endpoint for adding existing employees to team
      final response = await dio.post('/api/auth/employees/add/', data: request.toJson());
      
      if (response.statusCode == 200) {
        // Backend returns success response with employee data
        final responseData = response.data;
        if (responseData['success'] == true && responseData['employee'] != null) {
          return Employee.fromJson(responseData['employee']);
        }
      }
      
      throw Exception('Failed to add employee to team: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          final errorData = e.response?.data;
          if (errorData is Map && errorData.containsKey('error')) {
            throw Exception(errorData['error']);
          }
        } else if (e.response?.statusCode == 404) {
          throw Exception('Employee not found with the provided email. The employee must register first before being added to a team.');
        }
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<Employee> registerEmployee(EmployeeRegistrationRequest request) async {
    try {
      final response = await dio.post('/api/auth/register/', data: request.toJson());
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Employee.fromJson(response.data);
      }
      
      throw Exception('Failed to register employee: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          final errorData = e.response?.data;
          if (errorData is Map && errorData.containsKey('error')) {
            throw Exception(errorData['error']);
          }
        }
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateEmployeeRole(String username, String newRole) async {
    try {
      final response = await dio.put(
        '/api/auth/users/update-role/',
        data: {
          'username': username,
          'new_role': newRole,
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update employee role: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<List<Employee>> getEmployeesByManager() async {
    try {
      final response = await dio.get('/api/auth/employees/list/');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['employees'] != null) {
          return (data['employees'] as List)
              .map((json) => Employee.fromJson(json))
              .toList();
        }
      }
      
      throw Exception('Failed to load managed employees: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateEmployeeStatus(String username, bool isActive) async {
    try {
      final response = await dio.put(
        '/api/auth/employees/update-status/',
        data: {
          'username': username,  // Backend expects 'username' not 'employee_id'
          'is_active': isActive,
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update employee status: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<PayrollInfo> createPayrollEntry(PayrollCreateRequest request) async {
    try {
      final response = await dio.post('/api/payroll/create/', data: request.toJson());
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        if (data['payroll_entry'] != null) {
          return PayrollInfo.fromJson(data['payroll_entry']);
        } else {
          return PayrollInfo.fromJson(data);
        }
      }
      
      throw Exception('Failed to create payroll entry: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          final errorData = e.response?.data;
          if (errorData is Map && errorData.containsKey('error')) {
            throw Exception(errorData['error']);
          }
        }
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<List<PayrollInfo>> getPayrollEntries() async {
    try {
      final response = await dio.get('/api/payroll/schedule/');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['payroll_entries'] != null) {
          return (data['payroll_entries'] as List)
              .map((json) => PayrollInfo.fromJson(json))
              .toList();
        }
      }
      
      throw Exception('Failed to load payroll entries: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<Payslip> createPayslip(PayslipCreateRequest request) async {
    try {
      final response = await dio.post('/api/payslips/create/', data: request.toJson());
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        if (data['payslip'] != null) {
          return Payslip.fromJson(data['payslip']);
        } else {
          return Payslip.fromJson(data);
        }
      }
      
      throw Exception('Failed to create payslip: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          final errorData = e.response?.data;
          if (errorData is Map && errorData.containsKey('error')) {
            throw Exception(errorData['error']);
          }
        }
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<List<Payslip>> getPayslips({String? employeeId, String? status}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (employeeId != null) queryParams['employee_id'] = employeeId;
      if (status != null) queryParams['status'] = status;

      final response = await dio.get(
        '/api/payslips/list/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['payslips'] != null) {
          return (data['payslips'] as List)
              .map((json) => Payslip.fromJson(json))
              .toList();
        }
      }
      
      throw Exception('Failed to load payslips: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<String> generatePayslipPdf(String payslipId) async {
    try {
      final response = await dio.post(
        '/api/payslips/generate-pdf/',
        data: {'payslip_id': payslipId},
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        return data['pdf_data'] as String? ?? data['file_path'] as String;
      }
      
      throw Exception('Failed to generate payslip PDF: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<void> sendPayslipEmail(String payslipId) async {
    try {
      final response = await dio.post(
        '/api/payslips/send-email/',
        data: {'payslip_id': payslipId},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to send payslip email: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<void> processPayslipPayment(String payslipId) async {
    try {
      final response = await dio.post(
        '/api/payslips/process-payment/',
        data: {'payslip_id': payslipId},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to process payslip payment: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<PayrollBatchResult> processBatchPayroll(PayrollBatchRequest request) async {
    try {
      print("📤 Processing batch payroll with ${request.employees.length} employees");

      final response = await dio.post(
        '/api/payroll/process-batch/',
        data: request.toJson(),
      );

      print("📥 Batch payroll response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['batch_result'] != null) {
          return PayrollBatchResult.fromJson(data['batch_result']);
        } else {
          return PayrollBatchResult.fromJson(data);
        }
      }

      throw Exception('Failed to process batch payroll: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          final errorData = e.response?.data;
          if (errorData is Map && errorData.containsKey('error')) {
            throw Exception(errorData['error']);
          }
        }
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }
}