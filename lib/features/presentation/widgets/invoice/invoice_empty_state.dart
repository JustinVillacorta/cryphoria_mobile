import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvoiceEmptyState extends StatelessWidget {
  final bool isTablet;

  const InvoiceEmptyState({
    Key? key,
    this.isTablet = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: isTablet ? 64 : 56,
            color: const Color(0xFF6B6B6B).withValues(alpha: 0.4),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            'No invoices found',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 19 : 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),
          SizedBox(height: isTablet ? 10 : 8),
          Text(
            'Try adjusting your search or filter',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 15 : 14,
              color: const Color(0xFF6B6B6B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}