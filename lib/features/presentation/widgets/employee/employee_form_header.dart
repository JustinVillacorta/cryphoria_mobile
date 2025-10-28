import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeFormHeader extends StatelessWidget {
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;
  final VoidCallback onBackPressed;
  final String title;
  final String heading;
  final String subtitle;
  final IconData icon;

  const EmployeeFormHeader({
    Key? key,
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
    required this.onBackPressed,
    required this.title,
    required this.heading,
    required this.subtitle,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleSize = isDesktop ? 20.0 : isTablet ? 19.0 : 18.0;
    final headingSize = isDesktop ? 26.0 : isTablet ? 24.0 : 22.0;
    final subtitleSize = isDesktop ? 17.0 : isTablet ? 16.0 : 15.0;
    final iconSize = isDesktop ? 68.0 : isTablet ? 64.0 : 60.0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9747FF), Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 24 : isTablet ? 20 : 16,
            isSmallScreen ? 4 : 8,
            isDesktop ? 24 : isTablet ? 20 : 16,
            isSmallScreen ? 16 : 20,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: isTablet ? 26 : 24,
                    ),
                    onPressed: onBackPressed,
                  ),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(width: isTablet ? 52 : 48),
                ],
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(isTablet ? 18 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 14),
                  Text(
                    heading,
                    style: GoogleFonts.inter(
                      fontSize: headingSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: subtitleSize,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}