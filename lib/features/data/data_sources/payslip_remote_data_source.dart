
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

      final queryParams = <String, dynamic>{};
      if (employeeId != null) queryParams['employee_id'] = employeeId;
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await dio.get(
        '$baseUrl/api/payslips/list/',
        queryParameters: queryParams,
      );


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
      throw Exception('Failed to fetch payslips: $e');
    }
  }

  @override
  Future<PayslipModel> createPayslip(CreatePayslipRequest request) async {
    try {

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
      throw Exception('Failed to create payslip: $e');
    }
  }

  @override
  Future<String> generatePayslipPdf(String payslipId) async {
    try {

      final response = await dio.post(
        '$baseUrl/api/payslips/generate-pdf/',
        data: {'payslip_id': payslipId},
      );


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
      throw Exception('Failed to generate PDF: ${e.message}');
    } catch (e) {
      throw Exception('Failed to generate PDF: $e');
    }
  }

  @override
  Future<bool> sendPayslipEmail(String payslipId) async {
    try {

      final response = await dio.post(
        '$baseUrl/api/payslips/send-email/',
        data: {'payslip_id': payslipId},
      );


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
      throw Exception('Failed to send email: ${e.message}');
    } catch (e) {
      throw Exception('Failed to send email: $e');
    }
  }

  @override
  Future<bool> processPayslipPayment(String payslipId) async {
    try {

      final response = await dio.post(
        '$baseUrl/api/payslips/process-payment/',
        data: {'payslip_id': payslipId},
      );


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
      throw Exception('Failed to process payment: ${e.message}');
    } catch (e) {
      throw Exception('Failed to process payment: $e');
    }
  }

  @override
  Future<PayslipModel> getPayslipDetails(String payslipId) async {
    try {

      final response = await dio.get(
        '$baseUrl/api/payslips/details/',
        queryParameters: {'payslip_id': payslipId},
      );


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
      throw Exception('Failed to fetch payslip details: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch payslip details: $e');
    }
  }

  @override
  Future<PayslipsResponse> getPayrollDetails() async {
    try {

      final response = await dio.get(
        '$baseUrl/api/employee/payroll/details/',
      );


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
      throw Exception('Failed to fetch payroll details: $e');
    }
  }

  @override
  Future<PayrollEntryModel> getPayrollEntryDetails(String entryId) async {
    try {

      final response = await dio.get(
        '$baseUrl/api/employee/payroll/entry-details/',
        queryParameters: {'entry_id': entryId},
      );


      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;

        if (responseMap.containsKey('success')) {
        }
        if (responseMap.containsKey('payroll_entry')) {
        }
        if (responseMap.containsKey('entry')) {
        }
        if (responseMap.containsKey('data')) {
        }
        if (responseMap.containsKey('entry_id')) {
        }
        if (responseMap.containsKey('error')) {
        }
      }

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          try {
            if (responseData['success'] == true && responseData['payroll_entry'] != null) {
              return PayrollEntryModel.fromJson(responseData['payroll_entry']);
            }
            else if (responseData['success'] == true && responseData['entry'] != null) {
              return PayrollEntryModel.fromJson(responseData['entry']);
            }
            else if (responseData['success'] == true && responseData['data'] != null) {
              return PayrollEntryModel.fromJson(responseData['data']);
            }
            else if (responseData['entry_id'] != null) {
              return PayrollEntryModel.fromJson(responseData);
            }
            else if (responseData['error'] != null) {
              throw Exception(responseData['error']);
            }
            else {
              throw Exception('No valid entry data found in response');
            }
          } catch (e) {
            rethrow;
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to fetch payroll entry details: ${response.statusCode}');
      }
    } on DioException catch (e) {

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
      throw Exception('Failed to fetch payroll entry details: $e');
    }
  }
}