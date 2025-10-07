// lib/features/domain/usecases/process_payslip_payment_use_case.dart

import '../../repositories/payslip_repository.dart';

class ProcessPayslipPaymentUseCase {
  final PayslipRepository repository;

  ProcessPayslipPaymentUseCase(this.repository);

  Future<bool> call(String payslipId) async {
    return await repository.processPayslipPayment(payslipId);
  }
}