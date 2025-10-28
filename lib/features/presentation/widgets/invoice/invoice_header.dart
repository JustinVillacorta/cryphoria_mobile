import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvoiceHeader extends StatelessWidget {
  final bool isTablet;
  final bool isDesktop;

  const InvoiceHeader({
    super.key,
    this.isTablet = false,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invoices',
          style: GoogleFonts.inter(
            fontSize: isDesktop ? 28 : isTablet ? 26 : 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        SizedBox(height: isTablet ? 10 : 8),
        Text(
          'Invoices are automatically generated from transactions like payroll, payments sent through "Send Payment", and client payments received.',
          style: GoogleFonts.inter(
            fontSize: isTablet ? 15 : 14,
            color: const Color(0xFF6B6B6B),
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}