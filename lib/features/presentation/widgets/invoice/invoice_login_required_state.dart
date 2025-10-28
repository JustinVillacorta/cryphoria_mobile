import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvoiceLoginRequiredState extends StatelessWidget {
  final bool isTablet;

  const InvoiceLoginRequiredState({
    super.key,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.login_outlined,
            size: isTablet ? 64 : 56,
            color: const Color(0xFF6B6B6B).withValues(alpha: 0.4),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            'Please log in to view invoices',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}