import 'package:cryphoria_mobile/features/domain/entities/payslip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PayslipHistoryItem extends StatelessWidget {
  final Payslip payslip;
  final bool isSmallScreen;
  final bool isTablet;
  final VoidCallback onTap;

  const PayslipHistoryItem({
    super.key,
    required this.payslip,
    required this.isSmallScreen,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateSize = isTablet ? 16.0 : 15.0;
    final detailSize = isTablet ? 14.0 : 13.0;
    final amountSize = isTablet ? 18.0 : 17.0;
    final buttonSize = isTablet ? 14.0 : 13.0;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
      padding: EdgeInsets.all(isTablet ? 18 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${DateFormat('MMM dd').format(payslip.payPeriodStart)} - ${DateFormat('MMM dd, yyyy').format(payslip.payPeriodEnd)}',
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
                  'Pay Date: ${DateFormat('MMM dd, yyyy').format(payslip.payDate)}',
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
                '\$${payslip.finalNetPay.toStringAsFixed(2)}',
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
      case PayslipStatus.draft:
        return Colors.orange[600]!;
      case PayslipStatus.generated:
        return Colors.blue[600]!;
      case PayslipStatus.sent:
        return const Color(0xFF9747FF);
      case PayslipStatus.paid:
        return Colors.green[600]!;
      case PayslipStatus.cancelled:
        return Colors.red[600]!;
      case PayslipStatus.processing:
        return Colors.amber[600]!;
      case PayslipStatus.failed:
        return Colors.red[600]!;
      case PayslipStatus.pending:
        return Colors.grey[600]!;
    }
  }
}