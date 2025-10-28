import 'package:flutter/material.dart';
import 'payroll_summary_card.dart';

class PayrollSummaryCardsRow extends StatelessWidget {
  final int totalEmployees;
  final int activeEmployees;
  final double totalPaid;

  const PayrollSummaryCardsRow({
    super.key,
    required this.totalEmployees,
    required this.activeEmployees,
    required this.totalPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: PayrollSummaryCard(
              title: 'Total Employees',
              value: totalEmployees.toString(),
              icon: Icons.people,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PayrollSummaryCard(
              title: 'Active Employees',
              value: activeEmployees.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PayrollSummaryCard(
              title: 'Total Paid',
              value: '\$${totalPaid.toStringAsFixed(0)}',
              icon: Icons.attach_money,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}