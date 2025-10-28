import 'package:cryphoria_mobile/features/domain/entities/payslip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PayslipPaymentStatusCard extends StatelessWidget {
  final Payslip payslip;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;

  const PayslipPaymentStatusCard({
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
            'Payment Status',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Container(
            padding: EdgeInsets.all(isTablet ? 18 : 16),
            decoration: BoxDecoration(
              color: _getStatusColor(payslip.statusEnum).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(payslip.statusEnum).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(payslip.statusEnum),
                      color: _getStatusColor(payslip.statusEnum),
                      size: isTablet ? 22 : 20,
                    ),
                    SizedBox(width: isTablet ? 12 : 10),
                    Text(
                      payslip.statusEnum.displayName.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 17 : 16,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(payslip.statusEnum),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 12 : 14),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: isTablet ? 18 : 16,
                      color: const Color(0xFF6B6B6B),
                    ),
                    SizedBox(width: isTablet ? 10 : 8),
                    Text(
                      'Pay Date: ${DateFormat('MMMM dd, yyyy').format(payslip.payDate)}',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 15 : 14,
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(PayslipStatus status) {
    switch (status) {
      case PayslipStatus.draft:
        return Icons.edit_outlined;
      case PayslipStatus.generated:
        return Icons.check_circle_outlined;
      case PayslipStatus.sent:
        return Icons.send_outlined;
      case PayslipStatus.paid:
        return Icons.check_circle_outlined;
      case PayslipStatus.cancelled:
        return Icons.cancel_outlined;
      case PayslipStatus.processing:
        return Icons.hourglass_empty_outlined;
      case PayslipStatus.failed:
        return Icons.error_outline;
      case PayslipStatus.pending:
        return Icons.schedule_outlined;
    }
  }

  Color _getStatusColor(PayslipStatus status) {
    switch (status) {
      case PayslipStatus.draft:
        return const Color(0xFFF59E0B);
      case PayslipStatus.generated:
        return const Color(0xFF10B981);
      case PayslipStatus.sent:
        return const Color(0xFF9747FF);
      case PayslipStatus.paid:
        return const Color(0xFF10B981);
      case PayslipStatus.cancelled:
        return const Color(0xFFEF4444);
      case PayslipStatus.processing:
        return const Color(0xFFF59E0B);
      case PayslipStatus.failed:
        return const Color(0xFFEF4444);
      case PayslipStatus.pending:
        return const Color(0xFF6B6B6B);
    }
  }
}