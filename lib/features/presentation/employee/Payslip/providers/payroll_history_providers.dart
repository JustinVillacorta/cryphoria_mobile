
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/payroll_entry.dart';
import '../../../../domain/entities/payslip.dart';
import '../../../../domain/entities/payroll_statistics.dart';
import '../../../../domain/entities/create_payslip_request.dart';
import '../../../../domain/usecases/payslip/get_payroll_details_usecase.dart';
import '../../../../domain/usecases/payslip/get_payroll_entry_details_usecase.dart';
import '../../../../domain/usecases/payslip/get_user_payslips_use_case.dart';
import '../../../../../dependency_injection/riverpod_providers.dart';

final getPayrollDetailsUseCaseProvider = Provider<GetPayrollDetailsUseCase>((ref) {
  final repository = ref.watch(payslipRepositoryProvider);
  return GetPayrollDetailsUseCase(repository: repository);
});

final getPayrollEntryDetailsUseCaseProvider = Provider<GetPayrollEntryDetailsUseCase>((ref) {
  final repository = ref.watch(payslipRepositoryProvider);
  return GetPayrollEntryDetailsUseCase(repository: repository);
});

final getUserPayslipsUseCaseProvider = Provider<GetUserPayslipsUseCase>((ref) {
  final repository = ref.watch(payslipRepositoryProvider);
  return GetUserPayslipsUseCase(repository);
});

final payrollDetailsProvider = FutureProvider<PayslipsResponse>((ref) async {
  final useCase = ref.watch(getPayrollDetailsUseCaseProvider);
  return await useCase();
});

final payrollStatisticsProvider = Provider<PayrollStatistics?>((ref) {
  final payrollDetailsAsync = ref.watch(payrollDetailsProvider);
  return payrollDetailsAsync.when(
    data: (data) {
      final payslips = data.payslips;
      if (payslips.isEmpty) return null;

      final totalPayslips = payslips.length;
      final paidPayslips = payslips.where((p) => p.status?.toUpperCase() == 'PAID').length;
      final sentPayslips = payslips.where((p) => p.status?.toUpperCase() == 'SENT').length;
      final generatedPayslips = payslips.where((p) => p.status?.toUpperCase() == 'GENERATED').length;
      final totalAmount = payslips.fold<double>(0, (sum, p) => sum + p.finalNetPay);

      return PayrollStatistics(
        totalEntries: totalPayslips,
        completedPayments: paidPayslips,
        scheduledPayments: sentPayslips + generatedPayslips,
        failedPayments: 0,
        totalPaidUsd: totalAmount,
        totalPendingUsd: 0,
        cryptoBreakdown: {},
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

final payrollEntriesProvider = Provider<List<PayrollEntry>>((ref) {
  return [];
});

final payslipsProvider = Provider<List<Payslip>>((ref) {
  final payrollDetailsAsync = ref.watch(payrollDetailsProvider);
  return payrollDetailsAsync.when(
    data: (data) => data.payslips,
    loading: () => [],
    error: (_, __) => [],
  );
});

final payrollEntryDetailsProvider = FutureProvider.family<PayrollEntry, String>((ref, entryId) async {
  final useCase = ref.watch(getPayrollEntryDetailsUseCaseProvider);
  return await useCase(entryId);
});

final userPayslipsProvider = FutureProvider<List<Payslip>>((ref) async {
  final useCase = ref.watch(getUserPayslipsUseCaseProvider);
  return await useCase(PayslipFilter());
});