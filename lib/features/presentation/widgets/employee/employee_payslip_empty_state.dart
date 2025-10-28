import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeePayslipEmptyState extends StatelessWidget {
  final bool isTablet;

  const EmployeePayslipEmptyState({
    super.key,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isTablet ? 48 : 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: isTablet ? 56 : 48,
              color: const Color(0xFF6B6B6B).withValues(alpha: 0.4),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              'No payslips found',
              style: GoogleFonts.inter(
                fontSize: isTablet ? 17 : 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                height: 1.3,
              ),
            ),
            SizedBox(height: isTablet ? 8 : 6),
            Text(
              'This employee has no payslip records',
              style: GoogleFonts.inter(
                fontSize: isTablet ? 14 : 13,
                color: const Color(0xFF6B6B6B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}