import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/cardwallet.dart';

/// A reusable “glass” invoice‑item card.
class InvoiceItemCard extends StatelessWidget {
  /// e.g. “Expenses”
  final String title;

  /// e.g. “You paid for Payroll. Please view receipt.”
  final String description;

  /// e.g. “Paid”
  final String status;

  /// e.g. “₱12,950”
  final String amount;

  /// Called when the user taps “View receipt”
  final VoidCallback? onViewReceipt;

  const InvoiceItemCard({
    Key? key,
    required this.title,
    required this.description,
    required this.status,
    required this.amount,
    this.onViewReceipt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // left column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 4),

                  // Description and amount on same row, wraps if needed
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Flexible description
                      Expanded(
                        child: Text(
                          description,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Aligned amount (top right)
                      Text(
                        amount,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _Badge(label: status),
                      GestureDetector(
                        onTap: onViewReceipt,
                        child: const _Badge(label: 'View receipt'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}

/// Tiny helper for the pill‑style badges
class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white54)),
    );
  }
}