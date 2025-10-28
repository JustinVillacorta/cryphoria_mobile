import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeEmptyState extends StatelessWidget {
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;

  const EmployeeEmptyState({
    Key? key,
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconSize = isDesktop ? 140.0 : isTablet ? 130.0 : 120.0;
    final mainIconSize = isDesktop ? 72.0 : isTablet ? 68.0 : 64.0;
    final titleSize = isDesktop ? 22.0 : isTablet ? 21.0 : 20.0;
    final subtitleSize = isDesktop ? 16.0 : isTablet ? 15.5 : 15.0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: const Color(0xFF9747FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(iconSize / 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: iconSize * 0.15,
                    right: iconSize * 0.15,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF9747FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: iconSize * 0.2,
                    left: iconSize * 0.2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9747FF).withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    width: mainIconSize,
                    height: mainIconSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9747FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.people_outline,
                      color: Colors.white,
                      size: mainIconSize * 0.55,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 24 : 32),
            Text(
              'No employees yet',
              style: GoogleFonts.inter(
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.3,
                height: 1.2,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 10),
            Text(
              'Add your first employee to get started',
              style: GoogleFonts.inter(
                fontSize: subtitleSize,
                color: const Color(0xFF6B6B6B),
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}