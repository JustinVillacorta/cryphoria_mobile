// lib/features/domain/repositories/payslip_repository.dart

import '../entities/payslip.dart';
import '../entities/create_payslip_request.dart';

abstract class PayslipRepository {
  /// Get user payslips with optional filters
  Future<List<Payslip>> getUserPayslips({
    String? employeeId,
    PayslipStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Create a new payslip
  Future<Payslip> createPayslip(CreatePayslipRequest request);

  /// Generate PDF for a payslip
  Future<String> generatePayslipPdf(String payslipId);

  /// Send payslip via email
  Future<bool> sendPayslipEmail(String payslipId);

  /// Process payslip payment
  Future<bool> processPayslipPayment(String payslipId);

  /// Get detailed payslip information
  Future<Payslip> getPayslipDetails(String payslipId);
}