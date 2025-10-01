// lib/features/data/repositories_impl/payslip_repository_impl.dart

import '../../domain/entities/payslip.dart';
import '../../domain/entities/create_payslip_request.dart';
import '../../domain/repositories/payslip_repository.dart';
import '../data_sources/payslip_remote_data_source.dart';

class PayslipRepositoryImpl implements PayslipRepository {
  final PayslipRemoteDataSource remoteDataSource;

  PayslipRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Payslip>> getUserPayslips({
    String? employeeId,
    PayslipStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Convert status enum to string
      String? statusString;
      if (status != null) {
        statusString = status.value;
      }

      // Convert dates to strings
      String? startDateString;
      String? endDateString;
      if (startDate != null) {
        startDateString = startDate.toIso8601String().substring(0, 10); // YYYY-MM-DD
      }
      if (endDate != null) {
        endDateString = endDate.toIso8601String().substring(0, 10); // YYYY-MM-DD
      }

      return await remoteDataSource.getUserPayslips(
        employeeId: employeeId,
        status: statusString,
        startDate: startDateString,
        endDate: endDateString,
      );
    } catch (e) {
      throw Exception('Failed to load payslips: $e');
    }
  }

  @override
  Future<Payslip> createPayslip(CreatePayslipRequest request) async {
    try {
      return await remoteDataSource.createPayslip(request);
    } catch (e) {
      throw Exception('Failed to create payslip: $e');
    }
  }

  @override
  Future<String> generatePayslipPdf(String payslipId) async {
    try {
      return await remoteDataSource.generatePayslipPdf(payslipId);
    } catch (e) {
      throw Exception('Failed to generate payslip PDF: $e');
    }
  }

  @override
  Future<bool> sendPayslipEmail(String payslipId) async {
    try {
      return await remoteDataSource.sendPayslipEmail(payslipId);
    } catch (e) {
      throw Exception('Failed to send payslip email: $e');
    }
  }

  @override
  Future<bool> processPayslipPayment(String payslipId) async {
    try {
      return await remoteDataSource.processPayslipPayment(payslipId);
    } catch (e) {
      throw Exception('Failed to process payslip payment: $e');
    }
  }

  @override
  Future<Payslip> getPayslipDetails(String payslipId) async {
    try {
      return await remoteDataSource.getPayslipDetails(payslipId);
    } catch (e) {
      throw Exception('Failed to load payslip details: $e');
    }
  }
}