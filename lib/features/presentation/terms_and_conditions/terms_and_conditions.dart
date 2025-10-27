import 'package:flutter/material.dart';
import '../widgets/auth/terms_and_conditions_content.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
      ),
      body: const TermsAndConditionsContent(),
    );
  }
}