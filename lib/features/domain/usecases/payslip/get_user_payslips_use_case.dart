// lib/features/domain/usecases/get_user_payslips_use_case.dart

import '../../entities/payslip.dart';
import '../../entities/create_payslip_request.dart';
import '../../repositories/payslip_repository.dart';

class GetUserPayslipsUseCase {
  final PayslipRepository repository;

  GetUserPayslipsUseCase(this.repository);

  Future<List<Payslip>> call(PayslipFilter filter) async {
    return await repository.getUserPayslips(
      employeeId: filter.employeeId,
      status: filter.status,
      startDate: filter.startDate,
      endDate: filter.endDate,
    );
  }
}