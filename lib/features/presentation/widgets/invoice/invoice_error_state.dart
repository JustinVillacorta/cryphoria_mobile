import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvoiceErrorState extends StatelessWidget {
  final Object error;
  final bool isTablet;
  final double horizontalPadding;

  const InvoiceErrorState({
    Key? key,
    required this.error,
    this.isTablet = false,
    this.horizontalPadding = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isTablet ? 64 : 56,
            color: Colors.red.shade400,
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            'Error loading invoices',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 19 : 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),
          SizedBox(height: isTablet ? 10 : 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Text(
              '$error',
              style: GoogleFonts.inter(
                fontSize: isTablet ? 15 : 14,
                color: const Color(0xFF6B6B6B),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}