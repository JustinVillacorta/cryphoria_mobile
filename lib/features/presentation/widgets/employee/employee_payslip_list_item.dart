import 'package:cryphoria_mobile/features/domain/entities/payslip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EmployeePayslipListItem extends StatelessWidget {
  final Payslip payslip;
  final bool isSmallScreen;
  final bool isTablet;
  final VoidCallback onTap;

  const EmployeePayslipListItem({
    Key? key,
    required this.payslip,
    required this.isSmallScreen,
    required this.isTablet,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String payPeriod = '${DateFormat('MMM dd').format(payslip.payPeriodStart)} - ${DateFormat('MMM dd, yyyy').format(payslip.payPeriodEnd)}';
    final String payDate = DateFormat('MMM dd, yyyy').format(payslip.payDate);
    final String amount = '\$${payslip.finalNetPay.toStringAsFixed(2)}';

    final double cardPadding = isTablet ? 18 : 16;
    final double dateSize = isTablet ? 16 : 15;
    final double detailSize = isTablet ? 14 : 13;
    final double amountSize = isTablet ? 18 : 17;
    final double buttonSize = isTablet ? 13 : 12;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 14 : 12),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payPeriod,
                  style: GoogleFonts.inter(
                    fontSize: dateSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    height: 1.3,
                    letterSpacing: -0.1,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Text(
                  'Pay Date: $payDate',
                  style: GoogleFonts.inter(
                    fontSize: detailSize,
                    color: const Color(0xFF6B6B6B),
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 10),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 10 : 8,
                    vertical: isTablet ? 5 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(payslip.statusEnum).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(payslip.statusEnum).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    payslip.statusEnum.displayName,
                    style: GoogleFonts.inter(
                      fontSize: isTablet ? 12 : 11,
                      color: _getStatusColor(payslip.statusEnum),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                amount,
                style: GoogleFonts.inter(
                  fontSize: amountSize,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                  height: 1.2,
                ),
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 14,
                    vertical: isTablet ? 8 : 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: const Color(0xFF9747FF).withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'View',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9747FF),
                    fontSize: buttonSize,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PayslipStatus status) {
    switch (status) {
      case PayslipStatus.paid:
        return const Color(0xFF10B981);
      case PayslipStatus.generated:
        return const Color(0xFF3B82F6);
      case PayslipStatus.failed:
        return const Color(0xFFEF4444);
      case PayslipStatus.processing:
        return const Color(0xFFF59E0B);
      case PayslipStatus.pending:
      case PayslipStatus.draft:
        return const Color(0xFF6B6B6B);
      case PayslipStatus.sent:
        return const Color(0xFF9747FF);
      case PayslipStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }
}