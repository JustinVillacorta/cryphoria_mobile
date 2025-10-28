import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isLast;

  const EmployeeInfoRow({
    Key? key,
    required this.label,
    required this.value,
    required this.isSmallScreen,
    required this.isTablet,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSize = isTablet ? 15.0 : 14.0;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : (isSmallScreen ? 12 : 14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isTablet ? 130 : 110,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: fontSize,
                color: const Color(0xFF6B6B6B),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}