import '../entities/payroll_period.dart';

abstract class PayrollRepository {
  /// Payroll Periods Management
  Future<List<PayrollPeriod>> getPayrollPeriods();
  Future<PayrollPeriod> createPayrollPeriod(CreatePayrollPeriodRequest request);
  Future<PayrollPeriod> getPayrollPeriod(String periodId);
  Future<PayrollPeriod> updatePayrollPeriod(String periodId, Map<String, dynamic> updates);
  Future<void> deletePayrollPeriod(String periodId);
  Future<PayrollPeriod> processPayrollPeriod(String periodId);
  
  /// Payroll Entries Management
  Future<List<PayrollEntry>> getPayrollEntries(String periodId);
  Future<PayrollEntry> updatePayrollEntry(UpdatePayrollEntryRequest request);
  Future<void> processPayrollEntry(String entryId);
  Future<List<PayrollEntry>> getEmployeePayrollHistory(String employeeId);
  
  /// Payroll Analytics and Reports
  Future<PayrollSummary> getPayrollSummary(String periodId);
  Future<Map<String, dynamic>> getPayrollAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? department,
  });
  
  /// Bulk Operations
  Future<void> bulkProcessPayroll(List<String> entryIds);
  Future<List<PayrollEntry>> bulkUpdatePayrollEntries(List<UpdatePayrollEntryRequest> requests);
}
