// lib/features/data/data_sources/payslip_remote_data_source.dart

import 'package:dio/dio.dart';
import '../../domain/entities/create_payslip_request.dart';
import '../../domain/entities/payslip.dart';
import '../models/payslip_model.dart';
import '../models/payroll_entry_model.dart';

abstract class PayslipRemoteDataSource {
  Future<List<PayslipModel>> getUserPayslips({
    String? employeeId,
    String? status,
    String? startDate,
    String? endDate,
  });

  Future<PayslipModel> createPayslip(CreatePayslipRequest request);
  Future<String> generatePayslipPdf(String payslipId);
  Future<bool> sendPayslipEmail(String payslipId);
  Future<bool> processPayslipPayment(String payslipId);
  Future<PayslipModel> getPayslipDetails(String payslipId);
  Future<PayslipsResponse> getPayrollDetails();
  Future<PayrollEntryModel> getPayrollEntryDetails(String entryId);
}

class PayslipRemoteDataSourceImpl implements PayslipRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  PayslipRemoteDataSourceImpl({required this.dio, required this.baseUrl});

  @override
  Future<List<PayslipModel>> getUserPayslips({
    String? employeeId,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    try {
      print('Fetching user payslips with filters: {employeeId: $employeeId, status: $status, startDate: $startDate, endDate: $endDate}');

      // Build query parameters
      final queryParams = <String, dynamic>{};
      if (employeeId != null) queryParams['employee_id'] = employeeId;
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await dio.get(
        '$baseUrl/api/payslips/list/',
        queryParameters: queryParams,
      );

      print('Payslips response code: ${response.statusCode}');
      print('Payslips response: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map<String, dynamic>) {
          if (responseData['success'] == true && responseData['payslips'] != null) {
            final payslipsData = responseData['payslips'] as List;
            return payslipsData.map((data) => PayslipModel.fromJson(data)).toList();
          } else {
            throw Exception(responseData['error'] ?? 'Failed to fetch payslips');
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to fetch payslips: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException during payslips fetch: ${e.message}');
      
      String errorMessage = 'Failed to fetch payslips';
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['error']?.toString() ?? 
                        errorData['message']?.toString() ?? 
                        errorMessage;
        }
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Error fetching payslips: $e');
      throw Exception('Failed to fetch payslips: $e');
    }
  }

  @override
  Future<PayslipModel> createPayslip(CreatePayslipRequest request) async {
    try {
      print('Creating payslip: ${request.employeeName}');

      final data = {
        'employee_name': request.employeeName,
        'employee_id': request.employeeId,
        'employee_email': request.employeeEmail,
        'employee_wallet': request.employeeWallet,
        'department': request.department,
        'position': request.position,
        'salary_amount': request.salaryAmount,
        'salary_currency': request.salaryCurrency ?? 'USD',
        'cryptocurrency': request.cryptocurrency ?? 'ETH',
        'pay_period_start': request.payPeriodStart,
        'pay_period_end': request.payPeriodEnd,
        'pay_date': request.payDate,
        'tax_deduction': request.taxDeduction ?? 0.0,
        'insurance_deduction': request.insuranceDeduction ?? 0.0,
        'retirement_deduction': request.retirementDeduction ?? 0.0,
        'other_deductions': request.otherDeductions ?? 0.0,
        'overtime_pay': request.overtimePay ?? 0.0,
        'bonus': request.bonus ?? 0.0,
        'allowances': request.allowances ?? 0.0,
        'notes': request.notes,
      };

      final response = await dio.post(
        '$baseUrl/api/payslips/create/',
        data: data,
      );

      print('Create payslip response code: ${response.statusCode}');
      print('Create payslip response: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map<String, dynamic>) {
          if (responseData['success'] == true && responseData['payslip'] != null) {
            return PayslipModel.fromJson(responseData['payslip']);
          } else {
            throw Exception(responseData['error'] ?? 'Failed to create payslip');
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to create payslip: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException during payslip creation: ${e.message}');
      
      String errorMessage = 'Failed to create payslip';
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['error']?.toString() ?? 
                        errorData['message']?.toString() ?? 
                        errorMessage;
        }
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Error creating payslip: $e');
      throw Exception('Failed to create payslip: $e');
    }
  }

  @override
  Future<String> generatePayslipPdf(String payslipId) async {
    try {
      print('Generating PDF for payslip: $payslipId');

      final response = await dio.post(
        '$baseUrl/api/payslips/generate-pdf/',
        data: {'payslip_id': payslipId},
      );

      print('Generate PDF response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map<String, dynamic>) {
          if (responseData['success'] == true && responseData['pdf_data'] != null) {
            return responseData['pdf_data'];
          } else {
            throw Exception(responseData['error'] ?? 'Failed to generate PDF');
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to generate PDF: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException during PDF generation: ${e.message}');
      throw Exception('Failed to generate PDF: ${e.message}');
    } catch (e) {
      print('Error generating PDF: $e');
      throw Exception('Failed to generate PDF: $e');
    }
  }

  @override
  Future<bool> sendPayslipEmail(String payslipId) async {
    try {
      print('Sending payslip email for: $payslipId');

      final response = await dio.post(
        '$baseUrl/api/payslips/send-email/',
        data: {'payslip_id': payslipId},
      );

      print('Send email response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map<String, dynamic>) {
          return responseData['success'] == true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } on DioException catch (e) {
      print('DioException during email sending: ${e.message}');
      throw Exception('Failed to send email: ${e.message}');
    } catch (e) {
      print('Error sending email: $e');
      throw Exception('Failed to send email: $e');
    }
  }

  @override
  Future<bool> processPayslipPayment(String payslipId) async {
    try {
      print('Processing payment for payslip: $payslipId');

      final response = await dio.post(
        '$baseUrl/api/payslips/process-payment/',
        data: {'payslip_id': payslipId},
      );

      print('Process payment response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map<String, dynamic>) {
          return responseData['success'] == true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } on DioException catch (e) {
      print('DioException during payment processing: ${e.message}');
      throw Exception('Failed to process payment: ${e.message}');
    } catch (e) {
      print('Error processing payment: $e');
      throw Exception('Failed to process payment: $e');
    }
  }

  @override
  Future<PayslipModel> getPayslipDetails(String payslipId) async {
    try {
      print('Fetching payslip details for: $payslipId');

      final response = await dio.get(
        '$baseUrl/api/payslips/details/',
        queryParameters: {'payslip_id': payslipId},
      );

      print('Payslip details response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map<String, dynamic>) {
          if (responseData['success'] == true && responseData['payslip'] != null) {
            return PayslipModel.fromJson(responseData['payslip']);
          } else {
            throw Exception(responseData['error'] ?? 'Failed to fetch payslip details');
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to fetch payslip details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException during payslip details fetch: ${e.message}');
      throw Exception('Failed to fetch payslip details: ${e.message}');
    } catch (e) {
      print('Error fetching payslip details: $e');
      throw Exception('Failed to fetch payslip details: $e');
    }
  }

  @override
  Future<PayslipsResponse> getPayrollDetails() async {
    try {
      print('Fetching payroll details');

      final response = await dio.get(
        '$baseUrl/api/employee/payroll/details/',
      );

      print('Payroll details response code: ${response.statusCode}');
      print('Payroll details response: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map<String, dynamic>) {
          if (responseData['success'] == true) {
            return PayslipsResponse.fromJson(responseData);
          } else {
            throw Exception(responseData['error'] ?? 'Failed to fetch payroll details');
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to fetch payroll details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException during payroll details fetch: ${e.message}');
      
      String errorMessage = 'Failed to fetch payroll details';
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['error']?.toString() ?? 
                        errorData['message']?.toString() ?? 
                        errorMessage;
        }
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Error fetching payroll details: $e');
      throw Exception('Failed to fetch payroll details: $e');
    }
  }

  @override
  Future<PayrollEntryModel> getPayrollEntryDetails(String entryId) async {
    try {
      print('Fetching payroll entry details for: $entryId');

      final response = await dio.get(
        '$baseUrl/api/employee/payroll/entry-details/',
        queryParameters: {'entry_id': entryId},
      );

      print('Payroll entry details response code: ${response.statusCode}');
      print('Payroll entry details response: ${response.data}');
      print('Response data type: ${response.data.runtimeType}');
      print('Response data length: ${response.data.toString().length}');
      
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        print('Response keys: ${responseMap.keys.toList()}');
        print('Response values: ${responseMap.values.map((v) => v.runtimeType).toList()}');
        
        // Check for common response patterns
        if (responseMap.containsKey('success')) {
          print('Has success field: ${responseMap['success']}');
        }
        if (responseMap.containsKey('payroll_entry')) {
          print('Has payroll_entry field: ${responseMap['payroll_entry'] != null}');
        }
        if (responseMap.containsKey('entry')) {
          print('Has entry field: ${responseMap['entry'] != null}');
        }
        if (responseMap.containsKey('data')) {
          print('Has data field: ${responseMap['data'] != null}');
        }
        if (responseMap.containsKey('entry_id')) {
          print('Has entry_id field: ${responseMap['entry_id']}');
        }
        if (responseMap.containsKey('error')) {
          print('Has error field: ${responseMap['error']}');
        }
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map<String, dynamic>) {
          try {
            // Check if response has success field and payroll_entry field
            if (responseData['success'] == true && responseData['payroll_entry'] != null) {
              print('Parsing entry from success.payroll_entry field');
              return PayrollEntryModel.fromJson(responseData['payroll_entry']);
            }
            // Check if response has success field and entry field
            else if (responseData['success'] == true && responseData['entry'] != null) {
              print('Parsing entry from success.entry field');
              return PayrollEntryModel.fromJson(responseData['entry']);
            }
            // Check if response has success field and data field
            else if (responseData['success'] == true && responseData['data'] != null) {
              print('Parsing entry from success.data field');
              return PayrollEntryModel.fromJson(responseData['data']);
            }
            // Check if response is the entry data directly
            else if (responseData['entry_id'] != null) {
              print('Parsing entry directly from response');
              return PayrollEntryModel.fromJson(responseData);
            }
            // Check if response has error field
            else if (responseData['error'] != null) {
              print('Response contains error: ${responseData['error']}');
              throw Exception(responseData['error']);
            }
            // Default error
            else {
              print('No valid entry data found in response');
              print('Available fields: ${responseData.keys.toList()}');
              throw Exception('No valid entry data found in response');
            }
          } catch (e) {
            print('Error parsing PayrollEntryModel: $e');
            print('Response data that failed to parse: $responseData');
            rethrow;
          }
        } else {
          print('Response is not a Map<String, dynamic>, it is: ${responseData.runtimeType}');
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to fetch payroll entry details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException during payroll entry details fetch: ${e.message}');
      
      String errorMessage = 'Failed to fetch payroll entry details';
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['error']?.toString() ?? 
                        errorData['message']?.toString() ?? 
                        errorMessage;
        }
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Error fetching payroll entry details: $e');
      throw Exception('Failed to fetch payroll entry details: $e');
    }
  }
}