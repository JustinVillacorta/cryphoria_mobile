import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/payslip.dart';

class PayslipEarningsCard extends StatelessWidget {
  final Payslip payslip;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;

  const PayslipEarningsCard({
    super.key,
    required this.payslip,
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          payslip_amount_row(
            label: 'Base Salary',
            amount: payslip.baseSalary,
            isTotal: false,
            isTablet: isTablet,
          ),
          SizedBox(height: isSmallScreen ? 10 : 12),
          Divider(color: const Color(0xFFE5E5E5), thickness: 1.5),
          SizedBox(height: isSmallScreen ? 10 : 12),
          payslip_amount_row(
            label: 'Total Earnings',
            amount: payslip.totalEarnings,
            isTotal: true,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }
  
  // Helper widget for displaying a label and amount row
  // ignore: non_constant_identifier_names
  Widget payslip_amount_row({
    required String label,
    required double amount,
    required bool isTotal,
    required bool isTablet,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTablet ? 16 : 15,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? const Color(0xFF1A1A1A) : const Color(0xFF555555),
          ),
        ),
        Text(
          '₦${amount.toStringAsFixed(2)}',
          style: GoogleFonts.inter(
            fontSize: isTablet ? 16 : 15,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? const Color(0xFF1A1A1A) : const Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}