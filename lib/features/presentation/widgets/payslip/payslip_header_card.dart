import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cryphoria_mobile/features/domain/entities/payslip.dart';

class PayslipHeaderCard extends StatelessWidget {
  final Payslip payslip;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;

  const PayslipHeaderCard({
    Key? key,
    required this.payslip,
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9747FF), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9747FF).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isDesktop ? 70 : isTablet ? 65 : 60,
            height: isDesktop ? 70 : isTablet ? 65 : 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (payslip.employeeName ?? 'U').substring(0, 1).toUpperCase(),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: isDesktop ? 28 : isTablet ? 26 : 24,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ),
          SizedBox(width: isTablet ? 18 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payslip.employeeName ?? 'Unknown Employee',
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 22 : isTablet ? 20 : 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Text(
                  payslip.position ?? 'No position specified',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  payslip.department ?? 'No department specified',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 14 : 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.75),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}