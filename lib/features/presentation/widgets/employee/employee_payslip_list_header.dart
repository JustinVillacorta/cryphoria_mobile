import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeePayslipListHeader extends StatelessWidget {
  final int payslipCount;
  final bool isTablet;

  const EmployeePayslipListHeader({
    super.key,
    required this.payslipCount,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Payslips',
          style: GoogleFonts.inter(
            fontSize: isTablet ? 17 : 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            letterSpacing: -0.2,
            height: 1.3,
          ),
        ),
        SizedBox(height: isTablet ? 4 : 2),
        Text(
          '$payslipCount payslip${payslipCount == 1 ? '' : 's'} found',
          style: GoogleFonts.inter(
            fontSize: isTablet ? 14 : 13,
            color: const Color(0xFF6B6B6B),
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}