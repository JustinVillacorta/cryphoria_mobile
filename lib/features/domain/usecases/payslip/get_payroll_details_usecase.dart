// lib/features/domain/usecases/get_payroll_details_usecase.dart

import '../../entities/payroll_details_response.dart';
import '../../repositories/payslip_repository.dart';

class GetPayrollDetailsUseCase {
  final PayslipRepository repository;

  GetPayrollDetailsUseCase({required this.repository});

  Future<PayrollDetailsResponse> call() async {
    return await repository.getPayrollDetails();
  }
}
