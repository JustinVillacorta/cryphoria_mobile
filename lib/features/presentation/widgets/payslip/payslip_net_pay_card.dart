import 'package:cryphoria_mobile/features/domain/entities/payslip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PayslipNetPayCard extends StatelessWidget {
  final Payslip payslip;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;

  const PayslipNetPayCard({
    super.key,
    required this.payslip,
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 28 : isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'NET PAY',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 13 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 0.5,
              height: 1.3,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 10),
          Text(
            '\$${payslip.finalNetPay.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 42 : isTablet ? 38 : 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          if (payslip.cryptoAmount > 0) ...[
            SizedBox(height: isTablet ? 10 : 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 14 : 12,
                vertical: isTablet ? 8 : 7,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${payslip.cryptoAmount.toStringAsFixed(6)} ${payslip.cryptocurrency ?? 'ETH'}',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 14 : 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}