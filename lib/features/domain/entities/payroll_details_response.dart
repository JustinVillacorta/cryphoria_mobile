// lib/features/domain/entities/payroll_details_response.dart

import 'payroll_statistics.dart';
import 'payroll_entry.dart';
import 'payslip.dart';

class PayrollDetailsResponse {
  final bool success;
  final PayrollStatistics payrollStatistics;
  final List<PayrollEntry> payrollEntries;
  final List<Payslip> payslips;

  const PayrollDetailsResponse({
    required this.success,
    required this.payrollStatistics,
    required this.payrollEntries,
    required this.payslips,
  });

  factory PayrollDetailsResponse.fromJson(Map<String, dynamic> json) {
    return PayrollDetailsResponse(
      success: json['success'] as bool? ?? false,
      payrollStatistics: PayrollStatistics.fromJson(
        json['payroll_statistics'] as Map<String, dynamic>? ?? {},
      ),
      payrollEntries: (json['payroll_entries'] as List<dynamic>?)
          ?.map((e) => PayrollEntry.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      payslips: (json['payslips'] as List<dynamic>?)
          ?.map((e) => Payslip.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payroll_statistics': payrollStatistics.toJson(),
      'payroll_entries': payrollEntries.map((e) => e.toJson()).toList(),
      'payslips': payslips.map((e) => e.toJson()).toList(),
    };
  }
}
