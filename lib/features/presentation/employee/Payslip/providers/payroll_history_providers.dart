// lib/features/presentation/employee/Payslip/providers/payroll_history_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/payroll_details_response.dart';
import '../../../../domain/entities/payroll_entry.dart';
import '../../../../domain/entities/payslip.dart';
import '../../../../domain/entities/payroll_statistics.dart';
import '../../../../domain/usecases/get_payroll_details_usecase.dart';
import '../../../../domain/usecases/get_payroll_entry_details_usecase.dart';
import '../../../../../dependency_injection/riverpod_providers.dart';

// Provider for the use case
final getPayrollDetailsUseCaseProvider = Provider<GetPayrollDetailsUseCase>((ref) {
  final repository = ref.watch(payslipRepositoryProvider);
  return GetPayrollDetailsUseCase(repository: repository);
});

// Provider for payroll entry details use case
final getPayrollEntryDetailsUseCaseProvider = Provider<GetPayrollEntryDetailsUseCase>((ref) {
  final repository = ref.watch(payslipRepositoryProvider);
  return GetPayrollEntryDetailsUseCase(repository: repository);
});

// Provider for payroll details state
final payrollDetailsProvider = FutureProvider<PayrollDetailsResponse>((ref) async {
  final useCase = ref.watch(getPayrollDetailsUseCaseProvider);
  return await useCase();
});

// Provider for payroll statistics
final payrollStatisticsProvider = Provider<PayrollStatistics?>((ref) {
  final payrollDetailsAsync = ref.watch(payrollDetailsProvider);
  return payrollDetailsAsync.when(
    data: (data) => data.payrollStatistics,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Provider for payroll entries
final payrollEntriesProvider = Provider<List<PayrollEntry>>((ref) {
  final payrollDetailsAsync = ref.watch(payrollDetailsProvider);
  return payrollDetailsAsync.when(
    data: (data) => data.payrollEntries,
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider for payslips
final payslipsProvider = Provider<List<Payslip>>((ref) {
  final payrollDetailsAsync = ref.watch(payrollDetailsProvider);
  return payrollDetailsAsync.when(
    data: (data) => data.payslips,
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider for individual payroll entry details
final payrollEntryDetailsProvider = FutureProvider.family<PayrollEntry, String>((ref, entryId) async {
  final useCase = ref.watch(getPayrollEntryDetailsUseCaseProvider);
  return await useCase(entryId);
});
