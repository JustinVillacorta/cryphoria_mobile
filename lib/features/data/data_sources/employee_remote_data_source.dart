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
  Future<List<Employee>> getManagerTeamWithWallets(); // Get employees with wallet addresses
  Future<String?> getEmployeeWalletAddress(String userId); // Get specific employee wallet
  
  // Employee dashboard methods (for compatibility with old usecase)
  Future<Map<String, dynamic>> getEmployeeData(String employeeId);
  Future<Map<String, dynamic>> getWalletData(String employeeId);
  Future<Map<String, dynamic>> getPayoutInfo(String employeeId);
  Future<List<Map<String, dynamic>>> getRecentTransactions(String employeeId, {int limit = 5});
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
  Future<List<Employee>> getManagerTeamWithWallets() async {
    try {
      // First, get the proper employee data with correct names
      final employeeResponse = await dio.get('/api/auth/employees/list/');
      if (employeeResponse.statusCode != 200 || employeeResponse.data['employees'] == null) {
        throw Exception('Failed to load employee data');
      }
      
      // Then get payroll data for correlation
      final payrollResponse = await dio.get('/api/manager/payroll/employees/');
      Map<String, dynamic> payrollDataMap = {};
      
      // Create a map of payroll data by employee_id for quick lookup
      if (payrollResponse.statusCode == 200 && 
          payrollResponse.data['success'] == true && 
          payrollResponse.data['employees'] != null) {
        for (final payrollEmployee in payrollResponse.data['employees']) {
          final employeeId = payrollEmployee['employee_id'] as String?;
          if (employeeId != null) {
            payrollDataMap[employeeId] = payrollEmployee;
          }
        }
      }
      
      final employees = <Employee>[];
      
      // Process each employee from the proper employee endpoint
      for (final employeeData in employeeResponse.data['employees']) {
        try {
          print('DEBUG: Raw employee data from /api/auth/employees/list/: $employeeData');
          
          // Create employee using the proper Employee.fromJson method
          final employee = Employee.fromJson(employeeData);
          print('DEBUG: Created employee with name: ${employee.displayName}');
          
          // Get corresponding payroll data if available
          final employeeId = employee.userId;
          final payrollData = payrollDataMap[employeeId];
          
          // Create PayrollInfo from payroll data if available
          PayrollInfo? payrollInfo;
          if (payrollData != null) {
            final recentEntries = payrollData['recent_payroll_entries'] as List?;
            if (recentEntries != null && recentEntries.isNotEmpty) {
              final latestEntry = recentEntries.first as Map<String, dynamic>;
              payrollInfo = PayrollInfo.fromJson(latestEntry);
            }
          }
          
          // Try to get wallet address for this employee
          String? walletAddress;
          try {
            walletAddress = await getEmployeeWalletAddress(employee.userId);
            print('DEBUG: Found wallet for ${employee.displayName}: $walletAddress');
          } catch (e) {
            print('DEBUG: Failed to get wallet for employee ${employee.userId}: $e');
          }
          
          // Create updated payroll info with wallet address
          PayrollInfo? updatedPayrollInfo;
          if (payrollInfo != null) {
            updatedPayrollInfo = PayrollInfo(
              entryId: payrollInfo.entryId,
              employeeName: employee.displayName, // Use the correct employee name
              employeeWallet: walletAddress ?? payrollInfo.employeeWallet,
              salaryAmount: payrollInfo.salaryAmount,
              salaryCurrency: payrollInfo.salaryCurrency,
              paymentFrequency: payrollInfo.paymentFrequency,
              startDate: payrollInfo.startDate,
              isActive: payrollInfo.isActive,
              status: payrollInfo.status,
              usdEquivalent: payrollInfo.usdEquivalent,
              notes: payrollInfo.notes,
              createdAt: payrollInfo.createdAt,
              processedAt: payrollInfo.processedAt,
            );
          } else if (walletAddress != null) {
            // Create basic payroll info even if no payroll entries exist
            updatedPayrollInfo = PayrollInfo(
              employeeName: employee.displayName,
              employeeWallet: walletAddress,
              salaryAmount: 0.0,
              salaryCurrency: 'USD',
              paymentFrequency: 'MONTHLY',
              startDate: DateTime.now(),
              isActive: true,
              status: 'SCHEDULED',
            );
          }
          
          // Create updated employee with correct payroll info
          final updatedEmployee = Employee(
            userId: employee.userId,
            username: employee.username,
            email: employee.email,
            role: employee.role,
            isActive: employee.isActive,
            createdAt: employee.createdAt,
            lastLogin: employee.lastLogin,
            payrollInfo: updatedPayrollInfo,
            firstName: employee.firstName,
            lastName: employee.lastName,
            department: employee.department,
            position: employee.position,
            profileImage: employee.profileImage,
          );
          
          employees.add(updatedEmployee);
        } catch (e) {
          print('DEBUG: Error processing employee data: $e');
          // Continue with next employee
        }
      }
      
      return employees;
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<String?> getEmployeeWalletAddress(String userId) async {
    // TODO: Implement proper wallet lookup endpoint
    // For now, return null as the test endpoint has been removed
    print('DEBUG: Wallet lookup not implemented for user $userId');
    return null;
  }

  // Employee dashboard methods (using mock data to avoid 404 errors)
  @override
  Future<Map<String, dynamic>> getEmployeeData(String employeeId) async {
    // Return mock employee data instead of calling non-existent API
    return {
      'id': employeeId,
      'name': 'Employee User',
      'avatar_url': '',
    };
  }

  @override
  Future<Map<String, dynamic>> getWalletData(String employeeId) async {
    // Return mock wallet data instead of calling non-existent API
    return {
      'currency': 'ETH',
      'balance': 0.0,
      'converted_amount': 0.0,
      'converted_currency': 'USD',
    };
  }

  @override
  Future<Map<String, dynamic>> getPayoutInfo(String employeeId) async {
    // Return mock payout info instead of calling non-existent API
    final now = DateTime.now();
    final nextPayout = DateTime(now.year, now.month + 1, 30);
    return {
      'next_payout_date': nextPayout.toIso8601String(),
      'frequency': 'Monthly',
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentTransactions(String employeeId, {int limit = 5}) async {
    // Return mock transaction data instead of calling non-existent API
    return [
      {
        'id': '1',
        'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'amount': 0.5,
        'currency': 'ETH',
        'usdAmount': 1000.0,
        'status': 'Confirmed',
      },
      {
        'id': '2',
        'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'amount': 0.3,
        'currency': 'ETH',
        'usdAmount': 600.0,
        'status': 'Pending',
      },
    ];
  }

}