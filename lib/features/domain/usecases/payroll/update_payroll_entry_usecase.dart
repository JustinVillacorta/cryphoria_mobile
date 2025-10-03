import '../../entities/payroll_period.dart';
import '../../repositories/payroll_repository.dart';

class UpdatePayrollEntryUseCase {
  final PayrollRepository repository;

  UpdatePayrollEntryUseCase({required this.repository});

  Future<PayrollEntry> execute(UpdatePayrollEntryRequest request) async {
    _validateRequest(request);
    
    return await repository.updatePayrollEntry(request);
  }

  void _validateRequest(UpdatePayrollEntryRequest request) {
    if (request.entryId.isEmpty) {
      throw Exception('Entry ID cannot be empty');
    }

    if (request.baseSalary != null && request.baseSalary! < 0) {
      throw Exception('Base salary cannot be negative');
    }

    if (request.overtimeHours != null && request.overtimeHours! < 0) {
      throw Exception('Overtime hours cannot be negative');
    }

    if (request.overtimeRate != null && request.overtimeRate! < 0) {
      throw Exception('Overtime rate cannot be negative');
    }

    if (request.bonusAmount != null && request.bonusAmount! < 0) {
      throw Exception('Bonus amount cannot be negative');
    }

    // Validate allowances
    if (request.allowances != null) {
      for (final entry in request.allowances!.entries) {
        if (entry.value < 0) {
          throw Exception('Allowance "${entry.key}" cannot be negative');
        }
      }
    }

    // Validate deductions
    if (request.deductions != null) {
      for (final entry in request.deductions!.entries) {
        if (entry.value < 0) {
          throw Exception('Deduction "${entry.key}" cannot be negative');
        }
      }
    }
  }
}
