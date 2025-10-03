import 'package:dio/dio.dart';
import '../../domain/entities/payroll_period.dart';

abstract class PayrollRemoteDataSource {
  Future<List<PayrollPeriod>> getPayrollPeriods();
  Future<PayrollPeriod> createPayrollPeriod(CreatePayrollPeriodRequest request);
  Future<PayrollPeriod> getPayrollPeriod(String periodId);
  Future<PayrollPeriod> updatePayrollPeriod(String periodId, Map<String, dynamic> updates);
  Future<void> deletePayrollPeriod(String periodId);
  Future<PayrollPeriod> processPayrollPeriod(String periodId);
  Future<List<PayrollEntry>> getPayrollEntries(String periodId);
  Future<PayrollEntry> updatePayrollEntry(UpdatePayrollEntryRequest request);
  Future<void> processPayrollEntry(String entryId);
  Future<List<PayrollEntry>> getEmployeePayrollHistory(String employeeId);
  Future<PayrollSummary> getPayrollSummary(String periodId);
  Future<Map<String, dynamic>> getPayrollAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? department,
  });
  Future<void> bulkProcessPayroll(List<String> entryIds);
  Future<List<PayrollEntry>> bulkUpdatePayrollEntries(List<UpdatePayrollEntryRequest> requests);
}

class PayrollRemoteDataSourceImpl implements PayrollRemoteDataSource {
  final Dio dio;

  PayrollRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PayrollPeriod>> getPayrollPeriods() async {
    try {
      final response = await dio.get('/api/payroll/periods/');
      
      if (response.statusCode == 200) {
        final List<dynamic> periodsJson = response.data['periods'] ?? [];
        return periodsJson.map((json) => PayrollPeriod.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load payroll periods: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error loading payroll periods: ${e.message}');
    } catch (e) {
      throw Exception('Error loading payroll periods: $e');
    }
  }

  @override
  Future<PayrollPeriod> createPayrollPeriod(CreatePayrollPeriodRequest request) async {
    try {
      final response = await dio.post(
        '/api/payroll/periods/',
        data: request.toJson(),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return PayrollPeriod.fromJson(response.data['period']);
      } else {
        throw Exception('Failed to create payroll period: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['error'] != null) {
        throw Exception(e.response!.data['error']);
      }
      throw Exception('Network error creating payroll period: ${e.message}');
    } catch (e) {
      throw Exception('Error creating payroll period: $e');
    }
  }

  @override
  Future<PayrollPeriod> getPayrollPeriod(String periodId) async {
    try {
      final response = await dio.get('/api/payroll/periods/$periodId/');
      
      if (response.statusCode == 200) {
        return PayrollPeriod.fromJson(response.data['period']);
      } else {
        throw Exception('Failed to load payroll period: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error loading payroll period: ${e.message}');
    } catch (e) {
      throw Exception('Error loading payroll period: $e');
    }
  }

  @override
  Future<PayrollPeriod> updatePayrollPeriod(String periodId, Map<String, dynamic> updates) async {
    try {
      final response = await dio.put(
        '/api/payroll/periods/$periodId/',
        data: updates,
      );
      
      if (response.statusCode == 200) {
        return PayrollPeriod.fromJson(response.data['period']);
      } else {
        throw Exception('Failed to update payroll period: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['error'] != null) {
        throw Exception(e.response!.data['error']);
      }
      throw Exception('Network error updating payroll period: ${e.message}');
    } catch (e) {
      throw Exception('Error updating payroll period: $e');
    }
  }

  @override
  Future<void> deletePayrollPeriod(String periodId) async {
    try {
      final response = await dio.delete('/api/payroll/periods/$periodId/');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete payroll period: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['error'] != null) {
        throw Exception(e.response!.data['error']);
      }
      throw Exception('Network error deleting payroll period: ${e.message}');
    } catch (e) {
      throw Exception('Error deleting payroll period: $e');
    }
  }

  @override
  Future<PayrollPeriod> processPayrollPeriod(String periodId) async {
    try {
      final response = await dio.post('/api/payroll/periods/$periodId/process/');
      
      if (response.statusCode == 200) {
        return PayrollPeriod.fromJson(response.data['period']);
      } else {
        throw Exception('Failed to process payroll period: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['error'] != null) {
        throw Exception(e.response!.data['error']);
      }
      throw Exception('Network error processing payroll period: ${e.message}');
    } catch (e) {
      throw Exception('Error processing payroll period: $e');
    }
  }

  @override
  Future<List<PayrollEntry>> getPayrollEntries(String periodId) async {
    try {
      final response = await dio.get('/api/payroll/periods/$periodId/entries/');
      
      if (response.statusCode == 200) {
        final List<dynamic> entriesJson = response.data['entries'] ?? [];
        return entriesJson.map((json) => PayrollEntry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load payroll entries: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error loading payroll entries: ${e.message}');
    } catch (e) {
      throw Exception('Error loading payroll entries: $e');
    }
  }

  @override
  Future<PayrollEntry> updatePayrollEntry(UpdatePayrollEntryRequest request) async {
    try {
      final response = await dio.put(
        '/api/payroll/entries/${request.entryId}/',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        return PayrollEntry.fromJson(response.data['entry']);
      } else {
        throw Exception('Failed to update payroll entry: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['error'] != null) {
        throw Exception(e.response!.data['error']);
      }
      throw Exception('Network error updating payroll entry: ${e.message}');
    } catch (e) {
      throw Exception('Error updating payroll entry: $e');
    }
  }

  @override
  Future<void> processPayrollEntry(String entryId) async {
    try {
      final response = await dio.post('/api/payroll/entries/$entryId/process/');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to process payroll entry: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['error'] != null) {
        throw Exception(e.response!.data['error']);
      }
      throw Exception('Network error processing payroll entry: ${e.message}');
    } catch (e) {
      throw Exception('Error processing payroll entry: $e');
    }
  }

  @override
  Future<List<PayrollEntry>> getEmployeePayrollHistory(String employeeId) async {
    try {
      final response = await dio.get('/api/payroll/employees/$employeeId/history/');
      
      if (response.statusCode == 200) {
        final List<dynamic> entriesJson = response.data['entries'] ?? [];
        return entriesJson.map((json) => PayrollEntry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load employee payroll history: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error loading employee payroll history: ${e.message}');
    } catch (e) {
      throw Exception('Error loading employee payroll history: $e');
    }
  }

  @override
  Future<PayrollSummary> getPayrollSummary(String periodId) async {
    try {
      final response = await dio.get('/api/payroll/periods/$periodId/summary/');
      
      if (response.statusCode == 200) {
        return PayrollSummary.fromJson(response.data['summary']);
      } else {
        throw Exception('Failed to load payroll summary: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error loading payroll summary: ${e.message}');
    } catch (e) {
      throw Exception('Error loading payroll summary: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getPayrollAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? department,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }
      if (department != null) {
        queryParams['department'] = department;
      }

      final response = await dio.get(
        '/api/payroll/analytics/',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        return response.data['analytics'];
      } else {
        throw Exception('Failed to load payroll analytics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error loading payroll analytics: ${e.message}');
    } catch (e) {
      throw Exception('Error loading payroll analytics: $e');
    }
  }

  @override
  Future<void> bulkProcessPayroll(List<String> entryIds) async {
    try {
      final response = await dio.post(
        '/api/payroll/bulk-process/',
        data: {'entry_ids': entryIds},
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to bulk process payroll: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['error'] != null) {
        throw Exception(e.response!.data['error']);
      }
      throw Exception('Network error bulk processing payroll: ${e.message}');
    } catch (e) {
      throw Exception('Error bulk processing payroll: $e');
    }
  }

  @override
  Future<List<PayrollEntry>> bulkUpdatePayrollEntries(List<UpdatePayrollEntryRequest> requests) async {
    try {
      final response = await dio.put(
        '/api/payroll/bulk-update/',
        data: {
          'updates': requests.map((r) => r.toJson()).toList(),
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> entriesJson = response.data['entries'] ?? [];
        return entriesJson.map((json) => PayrollEntry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to bulk update payroll entries: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['error'] != null) {
        throw Exception(e.response!.data['error']);
      }
      throw Exception('Network error bulk updating payroll entries: ${e.message}');
    } catch (e) {
      throw Exception('Error bulk updating payroll entries: $e');
    }
  }
}
