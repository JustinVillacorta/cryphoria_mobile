import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeFormSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;
  final List<Widget> children;

  const EmployeeFormSectionCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardPadding = isDesktop ? 24.0 : isTablet ? 20.0 : 18.0;
    final titleSize = isDesktop ? 19.0 : isTablet ? 18.0 : 17.0;
    final iconSize = isTablet ? 24.0 : 22.0;

    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 10 : 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9747FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF9747FF),
                    size: iconSize,
                  ),
                ),
                SizedBox(width: isTablet ? 14 : 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}