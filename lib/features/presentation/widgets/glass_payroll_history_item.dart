import 'package:flutter/material.dart';
import '../../domain/entities/payroll_history.dart';
import 'payroll_history_card.dart';

class GlassPayrollHistoryItem extends StatelessWidget {
  final PayrollHistory payroll;
  final VoidCallback? onTap;

  const GlassPayrollHistoryItem({
    super.key,
    required this.payroll,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PayrollHistoryItem(
      payroll: payroll,
      onTap: onTap,
    );
  }
}