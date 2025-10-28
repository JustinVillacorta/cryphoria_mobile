import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeCard extends StatelessWidget {
  final dynamic employee;
  final double cardPadding;
  final bool isSmallScreen;
  final bool isTablet;
  final VoidCallback onTap;

  const EmployeeCard({
    Key? key,
    required this.employee,
    required this.cardPadding,
    required this.isSmallScreen,
    required this.isTablet,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatarRadius = isTablet ? 26.0 : 24.0;
    final nameFontSize = isTablet ? 17.0 : 16.0;
    final detailsFontSize = isTablet ? 14.0 : 13.0;

    final hasValidImage = employee.profileImage != null && 
                          employee.profileImage!.isNotEmpty &&
                          Uri.tryParse(employee.profileImage!)?.hasAbsolutePath == true;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
        padding: EdgeInsets.all(cardPadding),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF9747FF).withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: const Color(0xFF9747FF).withValues(alpha: 0.1),
                backgroundImage: hasValidImage
                    ? NetworkImage(employee.profileImage!)
                    : null,
                child: !hasValidImage
                    ? Icon(
                        Icons.person_outline,
                        color: const Color(0xFF9747FF),
                        size: avatarRadius * 0.9,
                      )
                    : null,
              ),
            ),
            SizedBox(width: isTablet ? 16 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    employee.name,
                    style: GoogleFonts.inter(
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: -0.2,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 5 : 6),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          employee.position ?? 'Employee',
                          style: GoogleFonts.inter(
                            fontSize: detailsFontSize,
                            color: const Color(0xFF6B6B6B),
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6B6B6B),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Text(
                        employee.employeeCode,
                        style: GoogleFonts.inter(
                          fontSize: detailsFontSize,
                          color: const Color(0xFF6B6B6B),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}