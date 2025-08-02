// lib/features/presentation/widgets/employee_card.dart

import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/glass_card.dart'; // your GlassCard

/// A frosted‐glass ListTile for an employee row.
class PayrollItemwidget extends StatelessWidget {
  /// URL for the avatar image
  final String avatarUrl;

  /// Employee name
  final String name;
  final String subtitle;
  final String amount;
  final String frequency;
  final VoidCallback? onTap;

  const PayrollItemwidget({
    Key? key,
    required this.avatarUrl,
    required this.name,
    required this.subtitle,
    required this.amount,
    required this.frequency,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // vertical centering
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(avatarUrl),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center, // center text
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(color: Colors.white)),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center, // center trailing
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    frequency,
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
