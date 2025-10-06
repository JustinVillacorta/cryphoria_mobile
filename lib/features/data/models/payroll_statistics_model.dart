// lib/features/data/models/payroll_statistics_model.dart

import '../../domain/entities/payroll_statistics.dart';

class PayrollStatisticsModel extends PayrollStatistics {
  const PayrollStatisticsModel({
    required super.totalEntries,
    required super.completedPayments,
    required super.scheduledPayments,
    required super.failedPayments,
    required super.totalPaidUsd,
    required super.totalPendingUsd,
    required super.cryptoBreakdown,
  });

  factory PayrollStatisticsModel.fromJson(Map<String, dynamic> json) {
    return PayrollStatisticsModel(
      totalEntries: json['total_entries'] as int? ?? 0,
      completedPayments: json['completed_payments'] as int? ?? 0,
      scheduledPayments: json['scheduled_payments'] as int? ?? 0,
      failedPayments: json['failed_payments'] as int? ?? 0,
      totalPaidUsd: (json['total_paid_usd'] as num?)?.toDouble() ?? 0.0,
      totalPendingUsd: (json['total_pending_usd'] as num?)?.toDouble() ?? 0.0,
      cryptoBreakdown: (json['crypto_breakdown'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, (value as num).toDouble())) ?? {},
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'total_entries': totalEntries,
      'completed_payments': completedPayments,
      'scheduled_payments': scheduledPayments,
      'failed_payments': failedPayments,
      'total_paid_usd': totalPaidUsd,
      'total_pending_usd': totalPendingUsd,
      'crypto_breakdown': cryptoBreakdown,
    };
  }

  PayrollStatistics toEntity() {
    return PayrollStatistics(
      totalEntries: totalEntries,
      completedPayments: completedPayments,
      scheduledPayments: scheduledPayments,
      failedPayments: failedPayments,
      totalPaidUsd: totalPaidUsd,
      totalPendingUsd: totalPendingUsd,
      cryptoBreakdown: cryptoBreakdown,
    );
  }
}
