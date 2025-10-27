import 'package:flutter/material.dart';
import 'glass_card.dart';

class SummaryGlassCard extends StatelessWidget {
  final String title;

  final String value;

  final TextStyle? titleStyle;

  final TextStyle? valueStyle;

  final EdgeInsets padding;

  const SummaryGlassCard({
    super.key,
    required this.title,
    required this.value,
    this.titleStyle,
    this.valueStyle,
    this.padding = const EdgeInsets.all(16),
  });

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