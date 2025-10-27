
import '../entities/payslip.dart';
import '../entities/create_payslip_request.dart';
import '../entities/payroll_entry.dart';

abstract class PayslipRepository {
  Future<List<Payslip>> getUserPayslips({
    String? employeeId,
    PayslipStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Payslip> createPayslip(CreatePayslipRequest request);

  Future<String> generatePayslipPdf(String payslipId);

  Future<bool> sendPayslipEmail(String payslipId);

  Future<bool> processPayslipPayment(String payslipId);

  Future<Payslip> getPayslipDetails(String payslipId);

  Future<PayslipsResponse> getPayrollDetails();

  Future<PayrollEntry> getPayrollEntryDetails(String entryId);
}