import 'package:flutter/material.dart';

class InvoiceLoadingState extends StatelessWidget {
  const InvoiceLoadingState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
        strokeWidth: 2.5,
      ),
    );
  }
}