import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeTobBarWidget extends StatelessWidget {
  final String employeeName;

  const EmployeeTobBarWidget({
    Key? key,
    required this.employeeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;
    
    final avatarRadius = isDesktop ? 24.0 : isTablet ? 22.0 : 20.0;
    final titleFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : 16.0;
    final subtitleFontSize = isDesktop ? 14.0 : isTablet ? 13.5 : 13.0;
    
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF9747FF).withOpacity(0.2),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: avatarRadius,
            backgroundColor: const Color(0xFF9747FF).withOpacity(0.1),
            child: Icon(
              Icons.person_outline,
              color: const Color(0xFF9747FF),
              size: avatarRadius * 0.9,
            ),
          ),
        ),
        SizedBox(width: isDesktop ? 16 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hi, $employeeName',
                style: GoogleFonts.inter(
                  color: const Color(0xFF1A1A1A),
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'How are you today?',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B6B6B),
                  fontSize: subtitleFontSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}