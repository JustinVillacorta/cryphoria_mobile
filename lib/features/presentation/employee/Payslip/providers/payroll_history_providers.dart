// lib/features/presentation/employee/Payslip/providers/payroll_history_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/payroll_entry.dart';
import '../../../../domain/entities/payslip.dart';
import '../../../../domain/entities/payroll_statistics.dart';
import '../../../../domain/entities/create_payslip_request.dart';
import '../../../../domain/usecases/payslip/get_payroll_details_usecase.dart';
import '../../../../domain/usecases/payslip/get_payroll_entry_details_usecase.dart';
import '../../../../domain/usecases/payslip/get_user_payslips_use_case.dart';
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

// Provider for get user payslips use case
final getUserPayslipsUseCaseProvider = Provider<GetUserPayslipsUseCase>((ref) {
  final repository = ref.watch(payslipRepositoryProvider);
  return GetUserPayslipsUseCase(repository);
});

// Provider for payroll details state
final payrollDetailsProvider = FutureProvider<PayslipsResponse>((ref) async {
  final useCase = ref.watch(getPayrollDetailsUseCaseProvider);
  return await useCase();
});

// Provider for payroll statistics (derived from payslips)
final payrollStatisticsProvider = Provider<PayrollStatistics?>((ref) {
  final payrollDetailsAsync = ref.watch(payrollDetailsProvider);
  return payrollDetailsAsync.when(
    data: (data) {
      final payslips = data.payslips;
      if (payslips.isEmpty) return null;
      
      // Calculate statistics from payslips
      final totalPayslips = payslips.length;
      final paidPayslips = payslips.where((p) => p.status?.toUpperCase() == 'PAID').length;
      final sentPayslips = payslips.where((p) => p.status?.toUpperCase() == 'SENT').length;
      final generatedPayslips = payslips.where((p) => p.status?.toUpperCase() == 'GENERATED').length;
      final totalAmount = payslips.fold<double>(0, (sum, p) => sum + p.finalNetPay);
      
      return PayrollStatistics(
        totalEntries: totalPayslips,
        completedPayments: paidPayslips,
        scheduledPayments: sentPayslips + generatedPayslips,
        failedPayments: 0, // No failed payments in the new API
        totalPaidUsd: totalAmount,
        totalPendingUsd: 0, // All amounts are considered paid in the new API
        cryptoBreakdown: {}, // Empty for now
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Provider for payroll entries (empty since new API only returns payslips)
final payrollEntriesProvider = Provider<List<PayrollEntry>>((ref) {
  return [];
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

// Provider for user payslips (shows correct PAID status)
final userPayslipsProvider = FutureProvider<List<Payslip>>((ref) async {
  final useCase = ref.watch(getUserPayslipsUseCaseProvider);
  // Get all payslips for the current user (no filter)
  return await useCase(PayslipFilter());
});
