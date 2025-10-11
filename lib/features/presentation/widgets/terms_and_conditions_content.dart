import 'package:flutter/material.dart';

/// Static Terms & Conditions content widget.
class TermsAndConditionsContent extends StatelessWidget {
  const TermsAndConditionsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    Widget sectionTitle(String text) => Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            text,
            style: theme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        );

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
            'Welcome to Cryphoria. By downloading, accessing, or using our application, '
            'you agree to the following Terms and Conditions. Please read them carefully '
            'before using our services.',
          ),

          // Acceptance of Terms
          sectionTitle('Acceptance of Terms'),
          paragraph(
            'By creating an account or using the app, you agree to comply with these '
            'Terms and Conditions and any applicable laws and regulations. If you do '
            'not agree, please discontinue using the app.',
          ),

          // Data Collection and Usage
          sectionTitle('Data Collection and Usage'),
          paragraph(
            'To provide our services, we collect and process certain information. This '
            'may include personal and business details such as employee names and '
            'business credentials, as well as financial data including budgets, wallet '
            'addresses, and transaction records. The information you provide will be '
            'used solely to deliver and improve our services in compliance with '
            'applicable data protection laws.',
          ),

          // Service Limitations
          sectionTitle('Service Limitations'),
          paragraph(
            'At present, the functionalities available within the app represent the '
            'full extent of our services, and we cannot guarantee additional features '
            'or services outside of what is currently provided.',
          ),

          // Financial Transactions Disclaimer
          sectionTitle('Financial Transactions Disclaimer'),
          paragraph(
            'Users are solely responsible for ensuring the accuracy of all wallet '
            'addresses and transaction details they enter. We are not liable for any '
            'loss of funds resulting from incorrect recipient information, fraudulent '
            'activities, or investment scams outside our platform.',
          ),

          // Use of AI and Automation
          sectionTitle('Use of AI and Automation'),
          paragraph(
            'Our application uses Artificial Intelligence (AI) and Large Language '
            'Models (LLMs) to automate certain accounting and financial tasks. While '
            'we strive for accuracy, automated outputs may not always be completely '
            'correct. Users are advised to carefully review all AI-generated reports '
            'and suggestions before making financial decisions, as we are not liable '
            'for decisions made solely on AI-generated content.',
          ),

          // User Responsibilities
          sectionTitle('User Responsibilities'),
          paragraph(
            'You are responsible for the accuracy of the data you provide and for '
            'safeguarding your account information. The app must be used only for '
            'lawful purposes, and any misuse for fraudulent or illegal activities '
            'will result in the termination of your access.',
          ),

          // Amendments
          sectionTitle('Amendments'),
          paragraph(
            'We reserve the right to update these Terms and Conditions at any time. '
            'Any changes will take effect immediately upon being published, and '
            'continued use of the app constitutes acceptance of the revised terms.',
          ),

          // Contact Us
          sectionTitle('Contact Us'),
          paragraph(
            'For questions or concerns about these Terms and Conditions, please '
            'contact us at: [email/contact info]',
          ),
        ],
      ),
    );
  }
}

