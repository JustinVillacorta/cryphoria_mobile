import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/cardwallet.dart';

/// A frosted-glass card for one payroll history entry.
/// • Sent items are compact (height 64).
/// • Failed items expand (height 120) to show the reason row.
class PayrollHistoryItem extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String subtitle;
  final String amount;
  final String date;
  final bool isFailed;
  final String? reason;
  final VoidCallback? onTap;

   PayrollHistoryItem({
    Key? key,
    required this.avatarUrl,
    required this.name,
    required this.subtitle,
    required this.amount,
    required this.date,
    this.isFailed = false,
    this.reason,
    this.onTap,
  })  : assert(
          !isFailed || (reason != null && reason.isNotEmpty),
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
        height: isFailed ? failedHeight : sentHeight,
        child: GlassCard(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isFailed ? 12 : 8, // tighter padding for sent
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
                      backgroundImage: NetworkImage(avatarUrl),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(color: Colors.white)),
                          const SizedBox(height: 2),
                          Text(subtitle,
                              style: const TextStyle(color: Colors.white54)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(amount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 2),
                        Text(date,
                            style: const TextStyle(color: Colors.white54)),
                      ],
                    ),
                  ],
                ),

                // ─── Failure row (only for failed items) ───────────
                if (isFailed) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.brightness_1,
                          size: 8, color: Colors.redAccent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Reason: $reason',
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
