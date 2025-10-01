// lib/features/data/data_sources/payslip_remote_data_source.dart

import 'package:dio/dio.dart';
import '../../domain/entities/create_payslip_request.dart';
import '../models/payslip_model.dart';

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
}