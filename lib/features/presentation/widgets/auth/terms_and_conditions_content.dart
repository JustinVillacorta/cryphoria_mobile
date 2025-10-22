import 'package:flutter/material.dart';

/// Static Terms & Conditions content widget.
class TermsAndConditionsContent extends StatelessWidget {
  const TermsAndConditionsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    Widget paragraph(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            text,
            style: theme.bodyMedium,
          ),
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terms and Conditions',
            style: theme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          paragraph(
            'Our platform is designed to automate cryptocurrency-based payroll distribution.\n'
            'At this time, the system only supports businesses or organizations that pay '
            'employees on a fixed monthly salary basis.\n'
            'The platform does not calculate or manage hourly wages, commissions, attendance '
            'records, or overtime pay.\n'
            'Managers are solely responsible for ensuring accurate payment amounts before '
            'initiating transactions.',
          ),
        ],
      ),
    );
  }
}

