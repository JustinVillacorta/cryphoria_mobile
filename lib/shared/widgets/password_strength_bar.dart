import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/shared/validation/validators.dart';

class PasswordStrengthBar extends StatelessWidget {
  final String password;
  final EdgeInsetsGeometry? padding;

  const PasswordStrengthBar({super.key, required this.password, this.padding});

  @override
  Widget build(BuildContext context) {
    final res = AppValidators.passwordStrength(password);
    final score = res.score.clamp(0.0, 1.0);
    final label = res.label;
    final theme = Theme.of(context);

    Color color;
    if (score < 0.2) {
      color = Colors.red;
    } else if (score < 0.4) {
      color = Colors.orange;
    } else if (score < 0.6) {
      color = Colors.amber;
    } else if (score < 0.8) {
      color = Colors.lightGreen;
    } else {
      color = Colors.green;
    }

    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: score,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Strength: $label',
                style: theme.textTheme.bodySmall,
              ),
              Row(children: [
                _Dot(active: AppValidators.validatePassword(password) == null),
                const SizedBox(width: 6),
                Text(
                  _buildCriteriaHint(password),
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                ),
              ])
            ],
          ),
        ],
      ),
    );
  }

  static String _buildCriteriaHint(String v) {
    final missing = <String>[];
    if (v.length < AppValidators.defaultPasswordMin) missing.add('${AppValidators.defaultPasswordMin}+ chars');
    if (!RegExp(r"[a-z]").hasMatch(v)) missing.add('lower');
    if (!RegExp(r"[A-Z]").hasMatch(v)) missing.add('upper');
    if (!RegExp(r"\d").hasMatch(v)) missing.add('digit');
    if (!RegExp(r"[^A-Za-z0-9]").hasMatch(v)) missing.add('symbol');
    if (v.contains(' ')) missing.add('no spaces');
    if (missing.isEmpty) return 'Looks good';
    return 'Need: ${missing.join(', ')}';
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Colors.green : Colors.grey[400],
      ),
    );
  }
}
