import 'package:cryphoria_mobile/features/domain/entities/payslip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'employee_info_card.dart';

class PayslipSummaryCard extends StatelessWidget {
  final List<Payslip> employeePayslips;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;

  const PayslipSummaryCard({
    super.key,
    required this.employeePayslips,
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final latestPayslip = employeePayslips.isNotEmpty ? employeePayslips.first : null;
    final totalPayslips = employeePayslips.length;
    final totalPaid = employeePayslips
        .where((p) => p.status == 'paid')
        .fold(0.0, (sum, payslip) => sum + payslip.finalNetPay);

    final amountSize = isDesktop ? 28.0 : isTablet ? 26.0 : 24.0;
    final labelSize = isDesktop ? 15.0 : isTablet ? 14.0 : 13.0;

    return EmployeeInfoCard(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Payslip Summary',
      isSmallScreen: isSmallScreen,
      isTablet: isTablet,
      isDesktop: isDesktop,
      children: [
        if (latestPayslip != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '\$${latestPayslip.finalNetPay.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: amountSize,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              Text(
                'Latest Net Pay',
                style: GoogleFonts.inter(
                  fontSize: labelSize,
                  color: const Color(0xFF6B6B6B),
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 18 : 22),
          _buildPayrollDetailRow(
            'Base Salary',
            '\$${latestPayslip.baseSalary.toStringAsFixed(2)}',
          ),
          SizedBox(height: isSmallScreen ? 14 : 16),
          Row(
            children: [
              Expanded(
                child: _buildPayrollDetailColumn(
                  'Total Deductions',
                  '\$${latestPayslip.totalDeductions.toStringAsFixed(2)}',
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: _buildPayrollDetailColumn(
                  'Net Pay',
                  '\$${latestPayslip.netAmount.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 18 : 22),
          Container(
            height: 1,
            color: const Color(0xFFE5E5E5),
          ),
          SizedBox(height: isSmallScreen ? 18 : 22),
          Text(
            'Deduction Breakdown',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 14),
          _buildDeductionRow('Tax', '\$${latestPayslip.taxDeduction.toStringAsFixed(2)}'),
          _buildDeductionRow('Insurance', '\$${latestPayslip.insuranceDeduction.toStringAsFixed(2)}'),
          _buildDeductionRow('Retirement', '\$${latestPayslip.retirementDeduction.toStringAsFixed(2)}'),
          _buildDeductionRow('Others', '\$${latestPayslip.otherDeductions.toStringAsFixed(2)}'),
        ] else ...[
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 40 : 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: isTablet ? 64 : 56,
                    color: const Color(0xFF6B6B6B).withValues(alpha: 0.4),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  Text(
                    'No payslips found',
                    style: GoogleFonts.inter(
                      fontSize: isTablet ? 18 : 17,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B6B6B),
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 10),
                  Text(
                    'Payslips will appear here once generated',
                    style: GoogleFonts.inter(
                      fontSize: isTablet ? 15 : 14,
                      color: const Color(0xFF6B6B6B),
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
        SizedBox(height: isSmallScreen ? 18 : 22),
        Container(
          padding: EdgeInsets.all(isTablet ? 20 : 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E5E5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$totalPayslips',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 24 : 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Total Payslips',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 13 : 12,
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 48,
                width: 1,
                color: const Color(0xFFE5E5E5),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${totalPaid.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 24 : 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Total Paid',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 13 : 12,
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPayrollDetailRow(String label, String value) {
    final labelSize = isTablet ? 15.0 : 14.0;
    final valueSize = isTablet ? 17.0 : 16.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: labelSize,
            color: const Color(0xFF6B6B6B),
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: valueSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildPayrollDetailColumn(String label, String value) {
    final labelSize = isTablet ? 14.0 : 13.0;
    final valueSize = isTablet ? 17.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: labelSize,
            color: const Color(0xFF6B6B6B),
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: valueSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildDeductionRow(String label, String amount) {
    final fontSize = isTablet ? 15.0 : 14.0;

    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              color: const Color(0xFF6B6B6B),
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: fontSize,
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