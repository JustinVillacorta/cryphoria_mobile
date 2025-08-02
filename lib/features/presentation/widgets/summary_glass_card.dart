import 'package:flutter/material.dart';
import 'glass_card.dart';

/// A simple glass-style summary card used across invoice and payroll screens.
class SummaryGlassCard extends StatelessWidget {
  /// Label displayed above the value.
  final String title;

  /// Main value text of the card.
  final String value;

  /// Optional style for the title text.
  final TextStyle? titleStyle;

  /// Optional style for the value text.
  final TextStyle? valueStyle;

  /// Padding around the content of the card.
  final EdgeInsets padding;

  const SummaryGlassCard({
    Key? key,
    required this.title,
    required this.value,
    this.titleStyle,
    this.valueStyle,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: titleStyle ?? const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: valueStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
