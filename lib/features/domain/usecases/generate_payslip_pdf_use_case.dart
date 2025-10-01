// lib/features/domain/usecases/generate_payslip_pdf_use_case.dart

import '../repositories/payslip_repository.dart';

class GeneratePayslipPdfUseCase {
  final PayslipRepository repository;

  GeneratePayslipPdfUseCase(this.repository);

  Future<String> call(String payslipId) async {
    return await repository.generatePayslipPdf(payslipId);
  }
}