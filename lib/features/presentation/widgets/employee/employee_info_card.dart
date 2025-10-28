import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeInfoCard extends StatelessWidget {
  final IconData? icon;
  final String title;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;
  final List<Widget> children;

  const EmployeeInfoCard({
    super.key,
    this.icon,
    required this.title,
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final cardPadding = isDesktop ? 24.0 : isTablet ? 20.0 : 18.0;
    final titleSize = isDesktop ? 18.0 : isTablet ? 17.0 : 16.0;
    final iconSize = isTablet ? 22.0 : 20.0;

    return Container(
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
      padding: EdgeInsets.all(cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: const Color(0xFF9747FF),
                  size: iconSize,
                ),
                SizedBox(width: isTablet ? 12 : 10),
              ],
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                  height: 1.3,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 18),
          ...children,
        ],
      ),
    );
  }
}