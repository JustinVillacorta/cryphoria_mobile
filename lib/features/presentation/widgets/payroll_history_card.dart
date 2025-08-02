import 'package:flutter/material.dart';
import '../../domain/entities/payroll_history.dart';
import 'glass_card.dart';

/// A frosted-glass card for one payroll history entry.
/// • Sent items are compact (height 93).
/// • Failed items expand (height 150) to show the reason row.
class PayrollHistoryItem extends StatelessWidget {
  final PayrollHistory payroll;
  final VoidCallback? onTap;

  PayrollHistoryItem({
    Key? key,
    required this.payroll,
    this.onTap,
  }) : assert(
  !payroll.isFailed || (payroll.reason != null && payroll.reason!.isNotEmpty),
  'Provide a non-empty reason when isFailed is true',
  ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // Heights you can adjust:
    final sentHeight = 93.0;
    final failedHeight = 150.0;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: payroll.isFailed ? failedHeight : sentHeight,
        child: GlassCard(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: payroll.isFailed ? 12 : 8, // tighter padding for sent
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ─── Top row (both types) ──────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(payroll.avatarUrl),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payroll.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            payroll.subtitle,
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          payroll.amount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          payroll.date,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ],
                ),
                // ─── Failure row (only for failed items) ───────────
                if (payroll.isFailed) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.brightness_1,
                          size: 8, color: Colors.redAccent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Reason: ${payroll.reason}',
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.redAccent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Transaction Failed',
                          style: TextStyle(
                              color: Colors.redAccent, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}