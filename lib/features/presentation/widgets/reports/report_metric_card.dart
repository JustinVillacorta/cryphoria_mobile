import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final bool isSmallScreen;
  final bool isTablet;

  const ReportMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.isSmallScreen,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final titleSize = isTablet ? 13.0 : 12.0;
    final valueSize = isTablet ? 17.0 : 16.0;
    final iconSize = isTablet ? 18.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: iconSize,
              ),
              SizedBox(width: isTablet ? 10 : 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B6B6B),
                    height: 1.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: valueSize,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
              height: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

