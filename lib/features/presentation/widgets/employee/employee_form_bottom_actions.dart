import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeFormBottomActions extends StatelessWidget {
  final bool isSubmitting;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final String submitButtonText;

  const EmployeeFormBottomActions({
    super.key,
    required this.isSubmitting,
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
    required this.onCancel,
    required this.onSubmit,
    required this.submitButtonText,
  });

  @override
  Widget build(BuildContext context) {
    final buttonPadding = isTablet ? 16.0 : 14.0;
    final fontSize = isTablet ? 17.0 : 16.0;
    final horizontalPadding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        isSmallScreen ? 14 : 16,
        horizontalPadding,
        isSmallScreen ? 14 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isSubmitting ? null : onCancel,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: buttonPadding),
                  side: BorderSide(
                    color: isSubmitting 
                        ? const Color(0xFFE5E5E5) 
                        : const Color(0xFF9747FF),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: isSubmitting 
                        ? const Color(0xFF6B6B6B) 
                        : const Color(0xFF9747FF),
                  ),
                ),
              ),
            ),
            SizedBox(width: isTablet ? 16 : 14),
            Expanded(
              child: ElevatedButton(
                onPressed: isSubmitting ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9747FF),
                  disabledBackgroundColor: const Color(0xFF9747FF).withValues(alpha: 0.5),
                  padding: EdgeInsets.symmetric(vertical: buttonPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor: const Color(0xFF9747FF).withValues(alpha: 0.3),
                ),
                child: isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      )
                    : Text(
                        submitButtonText,
                        style: GoogleFonts.inter(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}