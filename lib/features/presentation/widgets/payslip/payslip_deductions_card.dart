import 'package:cryphoria_mobile/features/domain/entities/payslip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'payslip_amount_row.dart';

class PayslipDeductionsCard extends StatelessWidget {
  final Payslip payslip;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;

  const PayslipDeductionsCard({
    super.key,
    required this.payslip,
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final hasDeductions = payslip.totalDeductions > 0;

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
            'Deductions',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          if (hasDeductions) ...[
            if (payslip.taxDeduction > 0) ...[
              PayslipAmountRow(
                label: 'Tax Deduction',
                amount: payslip.taxDeduction,
                isTotal: false,
                isTablet: isTablet,
              ),
              SizedBox(height: isSmallScreen ? 10 : 12),
            ],
            if (payslip.insuranceDeduction > 0) ...[
              PayslipAmountRow(
                label: 'Insurance',
                amount: payslip.insuranceDeduction,
                isTotal: false,
                isTablet: isTablet,
              ),
              SizedBox(height: isSmallScreen ? 10 : 12),
            ],
            if (payslip.retirementDeduction > 0) ...[
              PayslipAmountRow(
                label: 'Retirement',
                amount: payslip.retirementDeduction,
                isTotal: false,
                isTablet: isTablet,
              ),
              SizedBox(height: isSmallScreen ? 10 : 12),
            ],
            if (payslip.otherDeductions > 0) ...[
              PayslipAmountRow(
                label: 'Other Deductions',
                amount: payslip.otherDeductions,
                isTotal: false,
                isTablet: isTablet,
              ),
              SizedBox(height: isSmallScreen ? 10 : 12),
            ],
            Divider(color: const Color(0xFFE5E5E5), thickness: 1.5),
            SizedBox(height: isSmallScreen ? 10 : 12),
            PayslipAmountRow(
              label: 'Total Deductions',
              amount: payslip.totalDeductions,
              isTotal: true,
              isTablet: isTablet,
            ),
          ] else
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                child: Text(
                  'No deductions',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 15 : 14,
                    color: const Color(0xFF6B6B6B),
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}