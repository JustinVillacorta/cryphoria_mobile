import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PayslipAmountRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isTotal;
  final bool isTablet;

  const PayslipAmountRow({
    Key? key,
    required this.label,
    required this.amount,
    required this.isTotal,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 12 : 10,
        horizontal: isTablet ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color: isTotal ? const Color(0xFF9747FF).withValues(alpha: 0.1) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: isTotal ? Border.all(color: const Color(0xFF9747FF).withValues(alpha: 0.3), width: 1.5) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isTotal ? (isTablet ? 16 : 15) : (isTablet ? 15 : 14),
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: const Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: isTotal ? (isTablet ? 18 : 17) : (isTablet ? 16 : 15),
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal ? const Color(0xFF9747FF) : const Color(0xFF1A1A1A),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}