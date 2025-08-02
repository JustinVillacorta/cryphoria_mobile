// lib/domain/entities/payroll_history.dart
class PayrollHistory {
  final String avatarUrl;
  final String name;
  final String subtitle;
  final String amount;
  final String date;
  final bool isFailed;
  final String? reason;

  PayrollHistory({
    required this.avatarUrl,
    required this.name,
    required this.subtitle,
    required this.amount,
    required this.date,
    this.isFailed = false,
    this.reason,
  }) : assert(
  !isFailed || (reason != null && reason.isNotEmpty),
  'Provide a non-empty reason when isFailed is true',
  );
}