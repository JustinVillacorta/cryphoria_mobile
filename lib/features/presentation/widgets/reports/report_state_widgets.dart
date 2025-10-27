import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final bool isSmallScreen;
  final bool isTablet;
  final double horizontalPadding;

  const ReportErrorState({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    required this.isSmallScreen,
    required this.isTablet,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: isTablet ? 64 : 56,
              color: Colors.red.shade400,
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: isTablet ? 19 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                height: 1.3,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isTablet ? 15 : 14,
                color: const Color(0xFF6B6B6B),
                height: 1.4,
              ),
            ),
            SizedBox(height: isSmallScreen ? 24 : 28),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9747FF),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 28 : 24,
                  vertical: isTablet ? 14 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 16 : 15,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback onAction;
  final bool isSmallScreen;
  final bool isTablet;
  final double horizontalPadding;

  const ReportEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.onAction,
    required this.isSmallScreen,
    required this.isTablet,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isTablet ? 64 : 56,
              color: const Color(0xFF6B6B6B).withValues(alpha: 0.4),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: isTablet ? 19 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                height: 1.3,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 10),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: isTablet ? 15 : 14,
                color: const Color(0xFF6B6B6B),
                height: 1.4,
              ),
            ),
            SizedBox(height: isSmallScreen ? 24 : 28),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9747FF),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 28 : 24,
                  vertical: isTablet ? 14 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Refresh',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 16 : 15,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

