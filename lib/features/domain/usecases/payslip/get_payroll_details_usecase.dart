// lib/features/domain/usecases/get_payroll_details_usecase.dart

import '../../entities/payslip.dart';
import '../../repositories/payslip_repository.dart';

class GetPayrollDetailsUseCase {
  final PayslipRepository repository;

  GetPayrollDetailsUseCase({required this.repository});

  Future<PayslipsResponse> call() async {
    return await repository.getPayrollDetails();
  }
}
