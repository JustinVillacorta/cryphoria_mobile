
class PayrollStatistics {
  final int totalEntries;
  final int completedPayments;
  final int scheduledPayments;
  final int failedPayments;
  final double totalPaidUsd;
  final double totalPendingUsd;
  final Map<String, double> cryptoBreakdown;

  const PayrollStatistics({
    required this.totalEntries,
    required this.completedPayments,
    required this.scheduledPayments,
    required this.failedPayments,
    required this.totalPaidUsd,
    required this.totalPendingUsd,
    required this.cryptoBreakdown,
  });

  factory PayrollStatistics.fromJson(Map<String, dynamic> json) {
    return PayrollStatistics(
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
}