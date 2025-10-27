import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/employee.dart';

abstract class EmployeeRemoteDataSource {
  Future<List<Employee>> getAllEmployees();
  Future<List<Employee>> getManagerTeam();
  Future<Employee> addEmployeeToTeam(AddEmployeeToTeamRequest request);
  Future<Employee> registerEmployee(EmployeeRegistrationRequest request);
  Future<void> updateEmployeeRole(String username, String newRole);
  Future<List<Employee>> getEmployeesByManager();
  Future<void> updateEmployeeStatus(String username, bool isActive);
  Future<PayrollInfo> createPayrollEntry(PayrollCreateRequest request);
  Future<List<PayrollInfo>> getPayrollEntries();
  Future<Payslip> createPayslip(PayslipCreateRequest request);
  Future<List<Payslip>> getPayslips({String? employeeId, String? status});
  Future<String> generatePayslipPdf(String payslipId);
  Future<void> sendPayslipEmail(String payslipId);
  Future<void> processPayslipPayment(String payslipId);
  Future<List<Employee>> getManagerTeamWithWallets();
  Future<String?> getEmployeeWalletAddress(String userId);

  Future<Map<String, dynamic>> getEmployeeData(String employeeId);
  Future<Map<String, dynamic>> getWalletData(String employeeId);
  Future<Map<String, dynamic>> getPayoutInfo(String employeeId);
  Future<List<Map<String, dynamic>>> getRecentTransactions(String employeeId, {int limit = 5});

  Future<void> removeEmployeeFromTeam(String email);
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
      final response = await dio.get('/api/auth/employees/list/');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['employees'] != null && data['employees'] is List) {
            return (data['employees'] as List)
                .map((json) => Employee.fromJson(json as Map<String, dynamic>))
                .toList();
          } else {
            return [];
          }
        } else if (data is List) {
          return data
              .map((json) => Employee.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
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
      final response = await dio.post('/api/auth/employees/add/', data: request.toJson());

      if (response.statusCode == 200) {
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
          'username': username,
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
      final employeeResponse = await dio.get('/api/auth/employees/list/');
      if (employeeResponse.statusCode != 200 || employeeResponse.data['employees'] == null) {
        throw Exception('Failed to load employee data');
      }

      final payrollResponse = await dio.get('/api/manager/payroll/employees/');
      Map<String, dynamic> payrollDataMap = {};

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

      for (final employeeData in employeeResponse.data['employees']) {
        try {

          final employee = Employee.fromJson(employeeData);

          final employeeId = employee.userId;
          final payrollData = payrollDataMap[employeeId];

          PayrollInfo? payrollInfo;
          if (payrollData != null) {
            final recentEntries = payrollData['recent_payroll_entries'] as List?;
            if (recentEntries != null && recentEntries.isNotEmpty) {
              final latestEntry = recentEntries.first as Map<String, dynamic>;
              payrollInfo = PayrollInfo.fromJson(latestEntry);
            }
          }

          String? walletAddress;
            walletAddress = await getEmployeeWalletAddress(employee.userId);
          

          PayrollInfo? updatedPayrollInfo;
          if (payrollInfo != null) {
            updatedPayrollInfo = PayrollInfo(
              entryId: payrollInfo.entryId,
              employeeName: employee.displayName,
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
          debugPrint('⚠️ EmployeeRemoteDataSource.getManagerTeamWithWallets: Failed to add employee to list: $e');
          // Skip this employee and continue with the rest
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
    return null;
  }

  @override
  Future<Map<String, dynamic>> getEmployeeData(String employeeId) async {
    return {
      'id': employeeId,
      'name': 'Employee User',
      'avatar_url': '',
    };
  }

  @override
  Future<Map<String, dynamic>> getWalletData(String employeeId) async {
    return {
      'currency': 'ETH',
      'balance': 0.0,
      'converted_amount': 0.0,
      'converted_currency': 'USD',
    };
  }

  @override
  Future<Map<String, dynamic>> getPayoutInfo(String employeeId) async {
    final now = DateTime.now();
    final nextPayout = DateTime(now.year, now.month + 1, 30);
    return {
      'next_payout_date': nextPayout.toIso8601String(),
      'frequency': 'Monthly',
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentTransactions(String employeeId, {int limit = 5}) async {
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

  @override
  Future<void> removeEmployeeFromTeam(String email) async {
    try {
      final response = await dio.post(
        '/api/auth/employees/remove-from-team/',
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove employee from team: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

}