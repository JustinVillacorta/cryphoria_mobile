import '../../entities/payroll_period.dart';
import '../../repositories/payroll_repository.dart';

class CreatePayrollPeriodUseCase {
  final PayrollRepository repository;

  CreatePayrollPeriodUseCase({required this.repository});

  Future<PayrollPeriod> execute(CreatePayrollPeriodRequest request) async {
    // Validate the request
    _validateRequest(request);
    
    return await repository.createPayrollPeriod(request);
  }

  void _validateRequest(CreatePayrollPeriodRequest request) {
    if (request.periodNumber.isEmpty) {
      throw Exception('Period number cannot be empty');
    }

    if (request.startDate.isAfter(request.endDate)) {
      throw Exception('Start date cannot be after end date');
    }

    if (request.payDate.isBefore(request.endDate)) {
      throw Exception('Pay date should be on or after the end date');
    }

    if (request.employeeIds.isEmpty) {
      throw Exception('At least one employee must be selected');
    }

    if (request.currency.isEmpty) {
      throw Exception('Currency cannot be empty');
    }
  }
}
