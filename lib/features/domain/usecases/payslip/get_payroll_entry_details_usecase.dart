
import '../../entities/payroll_entry.dart';
import '../../repositories/payslip_repository.dart';

class GetPayrollEntryDetailsUseCase {
  final PayslipRepository repository;

  GetPayrollEntryDetailsUseCase({required this.repository});

  Future<PayrollEntry> call(String entryId) async {
    return await repository.getPayrollEntryDetails(entryId);
  }
}