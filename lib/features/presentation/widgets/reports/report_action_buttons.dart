import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportActionButtons extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onDownload;
  final bool isSmallScreen;
  final bool isTablet;

  const ReportActionButtons({
    super.key,
    required this.onClose,
    required this.onDownload,
    required this.isSmallScreen,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = isTablet ? 16.0 : 15.0;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onClose,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE5E5E5), width: 1.5),
              padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Close',
              style: GoogleFonts.inter(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
                height: 1.2,
              ),
            ),
          ),
        ),
        SizedBox(width: isTablet ? 14 : 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onDownload,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9747FF),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.download_outlined, size: isTablet ? 18 : 16),
                SizedBox(width: isTablet ? 10 : 8),
                Text(
                  'Download',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

