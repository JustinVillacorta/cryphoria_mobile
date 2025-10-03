import '../../repositories/payroll_repository.dart';

class GetPayrollAnalyticsUseCase {
  final PayrollRepository repository;

  GetPayrollAnalyticsUseCase({required this.repository});

  Future<Map<String, dynamic>> execute({
    DateTime? startDate,
    DateTime? endDate,
    String? department,
  }) async {
    // Validate date range if both dates are provided
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      throw Exception('Start date cannot be after end date');
    }

    return await repository.getPayrollAnalytics(
      startDate: startDate,
      endDate: endDate,
      department: department,
    );
  }
}
