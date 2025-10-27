import '../../domain/entities/payroll_period.dart';
import '../../domain/repositories/payroll_repository.dart';
import '../data_sources/payroll_remote_data_source.dart';

class PayrollRepositoryImpl implements PayrollRepository {
  final PayrollRemoteDataSource remoteDataSource;

  PayrollRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PayrollPeriod>> getPayrollPeriods() async {
    try {
      return await remoteDataSource.getPayrollPeriods();
    } catch (e) {
      throw Exception('Failed to get payroll periods: $e');
    }
  }

  @override
  Future<PayrollPeriod> createPayrollPeriod(CreatePayrollPeriodRequest request) async {
    try {
      return await remoteDataSource.createPayrollPeriod(request);
    } catch (e) {
      throw Exception('Failed to create payroll period: $e');
    }
  }

  @override
  Future<PayrollPeriod> getPayrollPeriod(String periodId) async {
    try {
      return await remoteDataSource.getPayrollPeriod(periodId);
    } catch (e) {
      throw Exception('Failed to get payroll period: $e');
    }
  }

  @override
  Future<PayrollPeriod> updatePayrollPeriod(String periodId, Map<String, dynamic> updates) async {
    try {
      return await remoteDataSource.updatePayrollPeriod(periodId, updates);
    } catch (e) {
      throw Exception('Failed to update payroll period: $e');
    }
  }

  @override
  Future<void> deletePayrollPeriod(String periodId) async {
    try {
      return await remoteDataSource.deletePayrollPeriod(periodId);
    } catch (e) {
      throw Exception('Failed to delete payroll period: $e');
    }
  }

  @override
  Future<PayrollPeriod> processPayrollPeriod(String periodId) async {
    try {
      return await remoteDataSource.processPayrollPeriod(periodId);
    } catch (e) {
      throw Exception('Failed to process payroll period: $e');
    }
  }

  @override
  Future<List<PayrollEntry>> getPayrollEntries(String periodId) async {
    try {
      return await remoteDataSource.getPayrollEntries(periodId);
    } catch (e) {
      throw Exception('Failed to get payroll entries: $e');
    }
  }

  @override
  Future<PayrollEntry> updatePayrollEntry(UpdatePayrollEntryRequest request) async {
    try {
      return await remoteDataSource.updatePayrollEntry(request);
    } catch (e) {
      throw Exception('Failed to update payroll entry: $e');
    }
  }

  @override
  Future<void> processPayrollEntry(String entryId) async {
    try {
      return await remoteDataSource.processPayrollEntry(entryId);
    } catch (e) {
      throw Exception('Failed to process payroll entry: $e');
    }
  }

  @override
  Future<List<PayrollEntry>> getEmployeePayrollHistory(String employeeId) async {
    try {
      return await remoteDataSource.getEmployeePayrollHistory(employeeId);
    } catch (e) {
      throw Exception('Failed to get employee payroll history: $e');
    }
  }

  @override
  Future<PayrollSummary> getPayrollSummary(String periodId) async {
    try {
      return await remoteDataSource.getPayrollSummary(periodId);
    } catch (e) {
      throw Exception('Failed to get payroll summary: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getPayrollAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? department,
  }) async {
    try {
      return await remoteDataSource.getPayrollAnalytics(
        startDate: startDate,
        endDate: endDate,
        department: department,
      );
    } catch (e) {
      throw Exception('Failed to get payroll analytics: $e');
    }
  }

  @override
  Future<void> bulkProcessPayroll(List<String> entryIds) async {
    try {
      return await remoteDataSource.bulkProcessPayroll(entryIds);
    } catch (e) {
      throw Exception('Failed to bulk process payroll: $e');
    }
  }

  @override
  Future<List<PayrollEntry>> bulkUpdatePayrollEntries(List<UpdatePayrollEntryRequest> requests) async {
    try {
      return await remoteDataSource.bulkUpdatePayrollEntries(requests);
    } catch (e) {
      throw Exception('Failed to bulk update payroll entries: $e');
    }
  }
}